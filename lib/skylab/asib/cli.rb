require  File.expand_path('../..', __FILE__)
require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/tite-color'
require 'skylab/porcelain/en'
require 'optparse'


module Skylab::Asib
  class OnFind
    extend Skylab::PubSub::Emitter
    emits :error, :ambiguous => :error, :not_found => :error, :not_provided => :error
  end
  module Styles
    include Skylab::Porcelain::TiteColor
    def em(s)  ; stylize(s, :green         )   end
    def hdr(s) ; stylize(s, :strong, :green)   end
    alias_method :pre, :em
  end
  class ActionEnumerator < Enumerator
    def filter &b
      self.class.new { |y| each { |*a| b.call(y, *a) } }
    end
    def visible
      filter { |y, a| y << a if a.visible? }
    end
  end
  class Runtime
    include Styles
    include Skylab::Porcelain::En
    attr_reader :actions
    def emit _, s
      $stderr.puts s
    end
    def find token
      yield(e = OnFind.new)
      found = nil
      if token
        matcher = /^#{Regexp.escape(token)}/
        actions.each do |kls|
          kls.name == token and found = [kls] and break;
          kls.names.detect { |n| matcher =~ n } and (found ||= []).push(kls)
        end
      end
      found or exp = "expecting {#{actions.map{ |a| em a.name } * '|'}}"
      token or return e.emit(:not_provided, exp)
      found or return e.emit(:not_found, "invalid command #{token.inspect}. #{exp}")
      found.size > 1 and return e.emit(:ambiguous, "ambiguous comand #{token.inspect}. " <<
        "did you mean #{oxford_comma found.map { |k| "#{pre k.name}" }}?")
      found.first
    end
    def initialize
      actions = self.class.to_s.match(/^(.+)::[^:]+$/)[1].split('::').push('Actions').reduce(Object) { |m, o| m.const_get(o) }
      @actions = ActionEnumerator.new { |y| actions.constants.each { |k| y << actions.const_get(k) } }
    end
    def invoke argv
      argv = argv.dup
      2 == argv.size and '-h' == argv.last and argv.reverse! # the alternative is uglier
      find(argv.shift) { |o| o.on_error { |s| return usage(s.message) } }.new(self).invoke(argv)
    end
    def program_name
      File.basename($PROGRAM_NAME)
    end
    def usage s=nil
      s and emit(:info, s)
      emit :info, "#{hdr 'usage:'} #{program_name} <action> [opts] [args]"
      emit :info, "try #{pre "#{program_name} -h"} for help"
      nil
    end
  end

  module Actions
  end

  module Action
    def self.extended mod
      mod.send(:include, ActionInstanceMethods)
      mod.send(:extend, ActionModuleMethods)
    end
  end

  class ArgumentSyntax
    def [] idx
      string.split(' ')[idx] or "<arg#{idx + 1}>"  # @hack
    end
    attr_reader :action
    def define s
      @string = s
    end
    def initialize action
      @action = action
      @string = nil
    end
    def parse! argv, args, action
      meth = action.execution_method
      parameters = meth.parameters
      action.class.option_syntax.any? and parameters.pop # ick
      count = Hash.new { |h, k| h[k] = 0 }
      parameters.each { |p| count[p.first] += 1 }
      error = ->(msg) { action.runtime.emit(:syntax_error, msg) ; false }
      requireds = ->(i) { parameters.select{ |p| :req == p.first }[i].last }
      min_arity = count[:req]
      max_arity = count.values.reduce(:+)
      argv.size < min_arity and return error["missing argument: #{requireds[argv.size]}"]
      argv.size > max_arity and return error["unexpected argument: #{argv[max_arity]}"]
      args[0, 0] = argv
      argv.clear
      meth
    end
    def string
      @string and return @string
      params = action.execution_method.parameters
      action.option_syntax.any? and params.pop
      params.map do |p|
        a, b = case p.first
               when :req ;
               when :opt ; ['[', ']']
               else      ; fail
               end
        "#{a}<#{p.last}>#{b}"
      end.join(' ')
    end
    alias_method :to_str, :string
  end

  class OptionSyntax < Struct.new(:definitions)
    include Styles
    def any?
      definitions.any?
    end
    def help e
      _ = {}
      OptionParser.new do |o|
        o.banner = "#{hdr 'options:'}"
        definitions.each { |d| o.instance_exec(_, &d) }
        e.emit(:help, o.to_s) # you could of course..
      end
      nil
    end
    def initialize
      self.definitions = []
    end
    def define &b
      definitions.push b
    end
    def parse! argv, args, action
      definitions.empty? and return true
      args.push(req = {})
      ret = true
      begin
        OptionParser.new do |o|
          o.on('-h', '--help') do
            action.class.help(action.runtime)
            ret = nil
          end
          definitions.each { |d| o.instance_exec(req, &d) }
        end.parse!(argv)
      rescue OptionParser::ParseError => e
        action.runtime.emit :optparse_parse_error, e
        ret = false
      end
      ret
    end
    def to_str
      definitions.empty? and return nil
      _ = {}
      OptionParser.new do |o|
        definitions.each { |d| o.instance_exec(_, &d) }
        return o.instance_variable_get('@stack')[2].instance_variable_get('@list').
          map { |s| "[#{s.short.first or s.long.first}#{s.arg}]" }.join(' ')
      end
    end
  end

  module ActionModuleMethods
    include Styles
    def action_module_init
      @aliases = []
      @argument_syntax = ArgumentSyntax.new(self)
      @desc = []
      @name = self.to_s.match(/^.+::([^:]+)$/)[1].gsub(/(?<=[a-z])([A-Z])/) { "-#{$1}" }.downcase
      @option_syntax = OptionSyntax.new
      @visible = true
    end
    def aliases *a
      a.any? ? @aliases.concat(a) : @aliases
    end
    def argument_syntax s=nil
      s ? @argument_syntax.define(s) : @argument_syntax
    end
    def desc *a
      a.any? ? @desc.concat(a) : @desc
    end
    def execution_method
      instance_method(:execute)
    end
    def self.extended mod
      mod.action_module_init
    end
    def help e
      e.emit(:help, "#{hdr 'usage:'} #{e.program_name} #{syntax}")
      case desc.size
      when 0 ;
      when 1 ; e.emit(:help, "#{hdr 'description:'} #{desc.first}")
      else   ; e.emit(:help, "#{hdr 'description:'}") ; desc.each { |s| e.emit(:help, s) }
      end
      option_syntax.any? and option_syntax.help(e)
      nil
    end
    attr_reader :name
    def names
      [name, * @aliases]
    end
    def option_syntax &b
      b ? @option_syntax.define(&b) : @option_syntax
    end
    def summary
      @desc[0..2]
    end
    def syntax
      [name, option_syntax.to_str, argument_syntax.to_str].compact.join(' ')
    end
    attr_accessor :visible
    alias_method :visible?, :visible
  end

  module ActionInstanceMethods
    include Styles
    alias_method :action, :class
    def emit _, s
      @runtime.emit _, s
    end
    def execution_method
      method(:execute)
    end
    def initialize runtime
      @runtime = runtime
    end
    alias_method :action_init, :initialize
    def invoke argv, &b
      args = []
      x = action.option_syntax.parse!(argv, args, self) or return( x.nil? ? nil : usage )
      meth = action.argument_syntax.parse!(argv, args, self) or return usage
      meth.call(*args, &b)
    end
    attr_reader :runtime
    def usage s = nil
      emit(:error, s) if s
      emit :usage, "#{hdr 'usage:'} #{runtime.program_name} #{action.syntax}"
      emit :usage, "try #{runtime.program_name} #{action.name} -h for help."
      nil
    end
  end

  class Cli < Runtime
  end

  class Actions::Help
    extend Action
    include Styles

    aliases '-h'

    desc "displays this screen."

    self.visible = false

    def action_syntax
      "{#{ runtime.actions.visible.map { |a| pre a.name } * '|' }}"
    end

    def action_help action_name
      runtime.find(action_name) do |o|
        o.on_error do |e|
          return emit(:error, e.message)
        end
      end.help(runtime)
    end

    def execute action_name=nil
      action_name and return action_help(action_name)
      emit :payload, "#{hdr 'usage:'} #{runtime.program_name} #{action_syntax} [opts] [args]"
      tbl = runtime.actions.visible.map { |action|  [action.name, action.summary] }
      emit :payload, (tbl.empty? ? "(no actions)" : "#{hdr 'actions:'}")
      width = tbl.reduce(0) { |m, o| o[0].length > m ? o[0].length : m }
      fmt = "  #{em "%#{width}s"}  %s"
      fmt2 = "  #{' ' * width}  %s"
      tbl.each do |row|
        runtime.emit :payload, (fmt % [row[0], row[1][0]])
        row[1].size > 1 and row[1][1..1].each { |s| runtime.emit(:payload, fmt2 % [s]) }
      end
      tbl.empty? or emit(:payload, "try #{pre "#{runtime.program_name} <action> -h"} for help on a command.")
      nil
    end
  end

  #### "app"

require 'skylab/slake/attribute-definer'
require 'skylab/face/path-tools'
require 'stringio' # whaetver
require 'skylab/test-support/test-support' # ick just for deindent

  #### "model" and utility classes and support

  class MyPathname < Pathname
    def pretty
      Skylab::Face::PathTools.pretty_path to_s
    end
  end


  #### "action" base class

  class MyAction
    extend Action
    extend ::Skylab::Slake::AttributeDefiner

    def self.inherited cls
      cls.action_module_init
    end

    meta_attribute :boolean
    def self.on_boolean_attribute name, _
      alias_method "#{name}?", name
    end

    meta_attribute :default

    meta_attribute :pathname
    def self.on_pathname_attribute name, _
      alias_method "#{name}_before_pathname=", "#{name}="
      define_method("#{name}=") do |path|
        send("#{name}_before_pathname=", MyPathname.new(path.to_s))
      end
    end

    def initialize *a
      action_init(*a)
      self.class.attributes.select { |k, v| v.key?(:default) }.each do |k, v|
        send("#{k}=", v[:default].respond_to?(:call) ? v[:default].call : v[:default])
      end
    end

    def skip m
      emit(:info, "#{m}, skipping")
      nil
    end

    def update_attributes! req
      req.each { |k, v| send("#{k}=", v) }
    end
  end


  #### "actions"

  class Actions::Put < MyAction
    desc "put the file"
    desc "(see config-make)"
    def execute path
      emit :info, "ok, sure: #{path}"
    end
  end

  class Actions::ConfigMake < MyAction

    desc "write the config file"

    attribute :dest, :pathname => true, :default => ->() { "#{ENV['HOME']}/.asibrc" }
    attribute :dry_run, :boolean => true, :default => false
    alias_method :dry?, :dry_run?

    option_syntax do |h|
      on('-n', '--dry-run', "dry run.") { h[:dry_run] = true }
    end

    def execute opts
      update_attributes! opts
      dest.exist? and return skip("already exists: #{dest.pretty}")
      dest.open('w+') do |fh|
        content = <<-HERE.unindent
          host = yourhost
          document_root = /path/to/your/doc/root
        HERE
        b = dry? ? nil : fh.write(content)
        emit :info, "wrote #{dest.pretty} (#{b} bytes)"
      end
      true
    end
  end
end

