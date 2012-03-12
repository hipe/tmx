require  File.expand_path('../..', __FILE__)
require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/tite-color'
require 'skylab/porcelain/en'
require 'optparse'

module Skylab::Porcelain::Bleeding
  module Styles
    include Skylab::Porcelain::En
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
  module ActionInstanceMethods
    include Styles
    alias_method :action, :class
    def action_init runtime
      @runtime = runtime
    end
    def emit _, s
      @runtime.emit _, s
    end
    def execution_method
      method :execute
    end
    def help o={}
      emit(:help, o[:message]) if o[:message]
      help_usage o
      help_desc if o[:full]
      help_list if o[:full]
      help_invite o
      nil
    end
    def help_desc
      desc = self.class.desc
      case desc.size
      when 0 ;
      when 1 ; emit(:help, "#{hdr 'description:'} #{desc.first}")
      else   ; emit(:help, "#{hdr 'description:'}") ; desc.each { |s| emit(:help, s) }
      end
    end
    def help_invite o
      emit(:help, "try #{pre "#{program_name} #{action.name} -h"} for help") unless o[:full]
    end
    def help_list
      action.option_syntax.any? and action.option_syntax.help(runtime)
    end
    def help_usage o
      emit :help, "#{hdr 'usage:'} #{program_name} #{action.syntax}"
    end
    alias_method :initialize, :action_init
    def program_name # @delegate
      runtime.program_name
    end
    def resolve! argv
      args = []
      ok = action.option_syntax.parse!(argv, args, self) or return (help unless ok.nil?)
      meth = action.argument_syntax.parse!(argv, args, self) or return help
      [meth, args]
    end
    attr_reader :runtime
  end
  class OnFind
    extend Skylab::PubSub::Emitter
    emits :error, :ambiguous => :error, :not_found => :error, :not_provided => :error
  end
  module NamespaceInstanceMethods
    include ActionInstanceMethods
    attr_reader :actions
    def action_modules
      [ actions_module, OfficiousActions ]
    end
    def action_syntax
      "{#{ actions.visible.map { |a| pre a.name } * '|' }}"
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
      found or exp = "expecting #{action_syntax}"
      token or return e.emit(:not_provided, exp)
      found or return e.emit(:not_found, "invalid command #{token.inspect}. #{exp}")
      found.size > 1 and return e.emit(:ambiguous, "ambiguous comand #{token.inspect}. " <<
        "did you mean #{oxford_comma found.map { |k| "#{pre k.name}" }}?")
      found.first
    end
    def help_invite o
      a, b = if o[:full] then ['<action>',   " on a particular action."]
                         else ['[<action>]'] end
      emit :help, "try #{pre "#{program_name} #{a} -h"} for help#{b}"
    end
    def help_list
      tbl = actions.visible.map { |action|  [action.name, action.summary] }
      emit :help, (tbl.empty? ? "(no actions)" : "#{hdr 'actions:'}")
      width = tbl.reduce(0) { |m, o| o[0].length > m ? o[0].length : m }
      fmt = "  #{em "%#{width}s"}  %s"
      fmt2 = "  #{' ' * width}  %s"
      tbl.each do |row|
        emit :help, (fmt % [row[0], row[1][0]])
        row[1].size > 1 and row[1][1..1].each { |s| emit(:help, fmt2 % [s]) }
      end
    end
    def help_usage o
      action_syntax = (false == o[:action_syntax]) ? '<action>' : self.action_syntax
      emit :help, "#{hdr 'usage:'} #{program_name} #{action_syntax} [opts] [args]"
    end
    def namespace_init
      @actions = ActionEnumerator.new do |y|
        action_modules.each { |m| m.constants.each { |k| y << m.const_get(k) } }
        # there is an anticpated issue above with fuzzy matching actions that have same name in different module
      end
    end
    def program_name
      "#{runtime.program_name} #{actions_module.name}" #!
    end
    def resolve! argv
      2 == argv.size and '-h' == argv.last and argv.reverse! # the alternative is uglier, but @todo
      action = find(argv.shift){ |o| o.on_error { |s| return help(message: s.message, action_syntax: false) } }
      transaction = action.build self
      huh = transaction.resolve! argv
      huh
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
    def parse! argv, args, transaction
      meth = transaction.execution_method
      parameters = meth.parameters
      transaction.action.option_syntax.any? and parameters.pop # ick
      count = Hash.new { |h, k| h[k] = 0 }
      parameters.each { |p| count[p.first] += 1 }
      error = ->(msg) { transaction.runtime.emit(:syntax_error, msg) ; false }
      requireds = ->(i) { parameters.select{ |p| :req == p.first }[i].last }
      min_arity = count[:req]
      max_arity = count.values.reduce(:+) if count[:rest].zero?
      argv.size < min_arity and return error["missing argument: #{requireds[argv.size]}"]
      argv.size > max_arity and return error["unexpected argument: #{argv[max_arity]}"] if max_arity
      args[0, 0] = argv
      argv.clear
      meth
    end
    def string
      @string and return @string
      params = action.parameters
      action.option_syntax.any? and params.pop
      params.map do |p|
        a, b = case p.first
               when :req  ;
               when :opt  ; %w([ ])
               when :rest ; %w([ [..]])
               else       ; fail
               end
        "#{a}<#{p.last}>#{b}"
      end.join(' ')
    end
    def to_str
      string # !
    end
  end
  class OptionSyntax < Struct.new(:definitions)
    include Styles
    def any?
      definitions.any?
    end
    def define &b
      definitions.push b
    end
    def help e
      _ = {}
      OptionParser.new do |o|
        o.banner = "#{hdr 'options:'}"
        definitions.each { |d| o.instance_exec(_, &d) }
        e.emit(:help, o.to_s)
      end
    end
    def initialize
      self.definitions = []
    end
    def parse! argv, args, transaction
      definitions.empty? and return true
      args.push(req = {})
      ret = true
      begin
        OptionParser.new do |o|
          o.on('-h', '--help') do
            transaction.help(full: true)
            ret = nil
          end
          definitions.each { |d| o.instance_exec(req, &d) }
        end.parse!(argv)
      rescue OptionParser::ParseError => e
        transaction.runtime.emit :optparse_parse_error, e
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
    def build runtime
      new runtime
    end
    def desc *a
      a.any? ? @desc.concat(a) : @desc
    end
    def self.extended mod
      mod.action_module_init
    end
    attr_reader :name
    def names
      [name, * @aliases]
    end
    def option_syntax &b
      b ? @option_syntax.define(&b) : @option_syntax
    end
    def parameters
      instance_method(:execute).parameters
    end
    def summary
      desc[0..2]
    end
    def syntax
      [name, option_syntax.to_str, argument_syntax.to_str].compact.join(' ')
    end
    def visible *a
      case a.size ; when 0 ; @visible ; when 1 ; @visible = a.first ; else fail end
    end
    attr_writer :visible
    alias_method :visible?, :visible
  end
  module Action
    def self.extended mod
      mod.send :include, ActionInstanceMethods
      mod.send :extend, ActionModuleMethods
    end
  end
  module Namespace
    def self.extended mod
      mod.send :extend, NamespaceModuleMethods
    end
  end
  module NamespaceModuleMethods
    include ActionModuleMethods
    def self.extended mod
      mod.namespace_module_init
    end
    def build runtime
      NamespaceAction.new(self, runtime)
    end
    alias_method :namespace_module_init, :action_module_init
    def parameters
      arr = NamespaceAction.parameters
      arr
    end
    alias_method :action_module_summary, :summary
    def summary
      desc.any? and return action_module_summary
      aa = build(nil).actions.visible.to_a
      ["child action#{'s' if aa.size != 1}: {#{build(nil).actions.visible.map{ |a| "#{pre a.name}" }.join('|')}}"]
    end
  end
  class NamespaceAction
    extend Action
    include NamespaceInstanceMethods
    attr_reader :actions_module
    def initialize namespace, runtime
      action_init runtime
      @actions_module = namespace
      namespace_init
    end
  end
  class Runtime
    extend NamespaceModuleMethods
    include NamespaceInstanceMethods
    def actions_module
      self.class.to_s.match(/^(.+)::[^:]+$/)[1].split('::').push('Actions').reduce(Object) { |m, o| m.const_get(o) }
    end
    def emit _, s
      $stderr.puts s
    end
    alias_method :initialize, :namespace_init
    def invoke argv
      argv = argv.dup
      (callable, args = resolve!(argv)) or return callable
      callable.receiver.send(callable.name, *args)
    end
    def program_name
      File.basename($PROGRAM_NAME)
    end
    def self.inherited mod
      mod.namespace_module_init
    end
  end
  module OfficiousActions
  end
  class OfficiousActions::Help
    extend Action

    aliases '-h'

    desc "displays this screen."

    visible false

    def action_help action_name
      action = runtime.find(action_name) do |o|
        o.on_error do |e|
          return emit(:error, e.message)
        end
      end
      action.build(runtime).help(full: true)
      nil
    end

    def execute action_name=nil
      action_name ? action_help(action_name) : runtime.help(full: true)
    end
  end
end

