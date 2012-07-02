require_relative '..'
require_relative 'core'
require 'skylab/pub-sub/emitter'
require 'optparse'

module Skylab::Porcelain::Bleeding
  extend ::Skylab::Autoloader
  module Styles
    include ::Skylab::Porcelain::En
    include ::Skylab::Porcelain::TiteColor
    extend self
    def em(s)  ; stylize(s, :green         )   end
    def hdr(s) ; stylize(s, :strong, :green)   end
    alias_method :pre, :em
  end
  module MetaInstanceMethods
    def aliases_inferred
      [reflector.to_s.match(/[^:]+$/)[0].gsub(/(?<=[a-z])([A-Z])/) { "-#{$1}" }.downcase]
    end
    alias_method :aliases, :aliases_inferred
    def desc
      []
    end
    def summary
      if desc
        desc[0..2]
      else
        ['fuct up generated summary'] # @todo
      end
    end
    def visible?
      true
    end
  end
  module ActionInstanceMethods
    include Styles
    def argument_syntax
      @argument_syntax ||= ArgumentSyntax.new(self)
    end
    def bound_invocation_method
      method(:invoke)
    end
    def emit *a
      if ! @parent
        fail("WHERE IS PARENT IN THIS #{self.class}:\n#{self.inspect}")
      end
      @parent.emit(*a)
    end
    def help o={}
      emit(:help, o[:message]) if o[:message]
      if o[:invite_only] then help_invite(o) ; return nil end
      help_usage o
      help_desc if o[:full]
      help_list if o[:full]
      help_invite o
      nil
    end
    def help_desc
      case desc.size
      when 0 ;
      when 1 ; emit(:help, "#{hdr 'description:'} #{desc.first}")
      else   ; emit(:help, "#{hdr 'description:'}") ; desc.each { |s| emit(:help, s) }
      end if desc
    end
    def help_invite o={}
      emit(:help, "try #{pre "#{program_name} -h"}#{o[:for] || ' for help'}") unless o[:full]
    end
    def help_list
      option_syntax.any? and option_syntax.help(@parent)
    end
    def help_usage o
      emit :help, "#{hdr 'usage:'} #{program_name} #{syntax}".strip
    end
    def option_syntax
      @option_syntax ||= option_syntax_class.build
    end
    def option_syntax_class
      OptionSyntax
    end
    def parameters # @todo:redundant
      reflector.instance_method(:invoke).parameters # self might be an inferred action documentor, e.g.
    end
    def program_name
      "#{@parent.program_name} #{aliases.first}"
    end
    def resolve argv # mutates argv
      args = []
      ok =   option_syntax.parse!(  argv, args, self) or return (help if false == ok)
      meth = argument_syntax.parse!(argv, args, self) or return help
      [meth, args]
    end
    def syntax
      [option_syntax.string, argument_syntax.string].compact.join(' ') # aliases.first
    end
  end
  module ActionKlassInstanceMethods
    include ActionInstanceMethods, MetaInstanceMethods
    def _klass ; self.class end
    alias_method :builder, :_klass
    alias_method :reflector, :_klass
  end
  module ActionModuleMethods
    def self.extended klass
      klass.send(:include, ActionKlassInstanceMethods)
    end
    def option_syntax
      option_syntax_class(os = option_syntax_class.build)
      yield os if block_given?
      os
    end
    def option_syntax_class k=nil
      k.nil? ? OptionSyntax : instance_exec(k, &(redef = ->(k2) {
        define_method(:option_syntax_class) { k2 }
        singleton_class.send(:define_method, :option_syntax_class) { |k3 = nil| k3.nil? ? k2 : instance_exec(k3, &redef) }
      }))
    end
  end
  ON_FIND = ::Skylab::PubSub::Emitter.new(:error, ambiguous: :error, not_found: :error, not_provided: :error)
  module NamespaceInstanceMethods
    include ActionInstanceMethods
    def find token, &error
      e = ON_FIND.new(error) ; matched = [] ; builder = nil # resolve the match now! (flyweighting)
      token or return e.emit(:not_provided, "expecting #{syntax}")
      matcher = /^#{Regexp.escape(token)}/
      actions.names.each do |act|
        first_match = act.aliases.grep(matcher).reduce do |_first_match, name|
          name == token and return act.builder # first whole match always wins
          _first_match # we only want any one of these per action
        end and begin
          matched.push(first_match) ; builder = act.builder
        end
      end
      case matched.size
      when 0 ; e.emit(:not_found, "invalid action #{token.inspect}. expecting #{syntax}")
      when 1 ; builder # fuzzy match with only one match
      else   ; e.emit(:ambiguous, "ambiguous action #{token.inspect}. " <<
                      "did you mean #{self.or matched.map{|n| "#{pre n}"}}?") end
    end
    def help_invite o
      a, b = if o[:full] then ['<action>',   " on a particular action."]
                         else ['[<action>]'] end
      emit :help, "try #{pre "#{program_name} #{a} -h"} for help#{b}"
    end
    def help_list
      tbl = actions.helps.visible.map { |h|  [h.aliases.first, (h.summary || [])] }
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
      syntax = (false == o[:syntax]) ? '<action>' : self.syntax
      emit :help, "#{hdr 'usage:'} #{program_name} #{syntax} [opts] [args]"
    end
    def resolve argv # mutates argv
      b = find(argv.shift) { |o| o.on_error { |e| return help(message: e.message, syntax: false) } }
      b.respond_to?(:build) or (Module == b.class and b = NamespaceInferred.new(b))
      ((o = b.build self).respond_to?(:resolve) ? o : RuntimeInferred.new(o, b)).resolve argv
    end
    def syntax
      "{#{ actions.names.visible.map { |a| pre a.aliases.first } * '|' }}"
    end
  end
  class Actions < ::Enumerator
    def self.[](*a) ; build(*a) end
    def self.build *actionss
      new do |y|
        actionss.each do |actions|
          actions.each do |meta|
            y << meta
          end
        end
      end
    end
    def filter &b
      self.class.new { |y| each { |*a| b.call(y, *a) } }
    end
    def _self ; self end
    alias_method :helps, :_self # hook for stubbing
    alias_method :names, :_self # hook for stubbing
    def visible
      filter { |y, a| y << a if a.visible? }
    end
  end
  class Constants < Actions
    def self.build mod
      flyweight = nil
      new do |y|
        mod.constants.each do |const|
          m = mod.const_get(const)
          y << (m.respond_to?(:action_meta) ? m.action_meta :
            (flyweight ||= MetaInferred.new).set!(m))
        end
      end
    end
  end
  class ArgumentSyntax
    def [] idx
      string.split(' ')[idx] or "<arg#{idx + 1}>"  # @hack
    end
    def define! s
      @string = s
    end
    def initialize syntax # @duck parameters(), option_syntax()
      @syntax = syntax
      @string = nil
    end
    def parse! argv, args, runtime # @duck bound_invocation_method, option_syntax, emit
      runtime.object_id == @syntax.object_id or fail("when? @todo")
      meth = runtime.bound_invocation_method
      parameters = meth.parameters
      runtime.option_syntax.any? and parameters.pop # ick
      count = Hash.new { |h, k| h[k] = 0 }
      parameters.each { |p| count[p.first] += 1 }
      error = ->(msg) { runtime.emit(:syntax_error, msg) ; false }
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
      params = @syntax.parameters
      @syntax.option_syntax.any? and params.pop
      params.map do |p|
        a, b = case p.first
               when :req  ;
               when :opt  ; %w([ ])
               when :rest ; %w([ [..]])
               else       ; fail("not expecting this token: #{p.first.inspect}")
               end
        "#{a}<#{p.last}>#{b}"
      end.join(' ')
    end
  end
  class OptionSyntax < Struct.new(:definitions, :documentor_class, :parser_class, :help_enabled)
    include Styles
    def self.build
      new([], ::OptionParser, ::OptionParser)
    end
    def any?
      definitions.any?
    end
    def build
      self.class.new(definitions.dup, documentor_class, parser_class, help_enabled)
    end
    def on_definition_added
      @on_definition_added ||= {}
    end
    def define! &b
      definitions.push b
      on_definition_added.each { |_, l| instance_exec(&l) }
    end
    def documentor
      @documentor ||= documentor_class.new.tap { |d| init_documentor(d) }
    end
    def help e
      one_big_string = documentor.help { |line| e.emit(:help, line) } and e.emit(:help, one_big_string)
    end
    def init_documentor doc
      on_definition_added[:documentor] ||= ->() { @documentor = nil ; $stderr.puts("NEATO!") }
      doc.banner = "#{hdr 'options:'}"
      _ = {} ; definitions.each { |d| doc.instance_exec(_, &d) }
    end
    def initialize *a
      @documentor = nil
      super(*a)
    end
    def parse! argv, args, runtime # @duck help, emit
      definitions.any? or help_enabled or return true
      args.push(req = {}) if definitions.any?
      ret = true
      begin
        parser_class.new do |o|
          o.on('-h', '--help') do
            runtime.help(full: true)
            ret = nil
          end
          definitions.each { |d| o.instance_exec(req, &d) }
        end.parse!(argv)
      rescue OptionParser::ParseError => e
        runtime.emit :optparse_parse_error, e
        ret and ret = false # if ret was already nil, no need to display help again
      end
      ret
    end
    def string
      definitions.empty? and return nil
      documentor.instance_variable_get('@stack')[2].instance_variable_get('@list'). # less hacky is out of scope
        map { |s| "[#{s.short.first or s.long.first}#{s.arg}]" if s.respond_to?(:short) }.compact.join(' ')
    end
  end
  class Runtime
    include NamespaceInstanceMethods, MetaInstanceMethods
    def actions
      Actions[ Constants[self.class::Actions], Officious.actions ]
    end
    def invoke argv
      (callable, args = resolve(argv = argv.dup)) or return callable
      callable.receiver.send(callable.name, *args)
    end
    def program_name
      (@program_name ||= nil) || File.basename($PROGRAM_NAME)
    end
    attr_writer :program_name
  end
  module Officious
    def self.actions
      Constants[self]
    end
  end
  class MetaInferred
    include MetaInstanceMethods
    attr_reader :reflector
    alias_method :builder, :reflector
    def initialize # @todo make less of these
    end
    def set! reflector
      @reflector = reflector ; self
    end
  end
  class DocumentorInferred < MetaInferred
    include ActionInstanceMethods
    def initialize client, reflector
      if client.instance_variable_defined?('@parent') and p = client.instance_variable_get('@parent')
        p.respond_to?(:emit) or raise ArgumentError.new("emitter? #{parent.class}") # @todo: remove
        @parent = p
      else
        fail("DocumentorInferred hack failed! need parent (proper runtime) from #{client.class}")
      end
      @parent = p # @todo: rename to "runtime" ?
      set!(reflector)
    end
  end
  class RuntimeInferred < DocumentorInferred
    def initialize built, builder
      @bound_invocation_method = built.method(:invoke)
      super
    end
    attr_reader :bound_invocation_method
  end
  class NamespaceInferred
    include NamespaceInstanceMethods, MetaInstanceMethods
    def actions
      Actions[ Constants[@modul_with_actions], Officious.actions ]
    end
    def build parent
      @parent = parent ; self
    end
    def initialize modul_with_actions
      @modul_with_actions = modul_with_actions
    end
    attr_reader :modul_with_actions
    alias_method :reflector, :modul_with_actions # for documentation generation
    alias_method :builder, :modul_with_actions   # for find
  end
  class Officious::Help
    include ActionKlassInstanceMethods
    def self.action_meta
      new # use an instance as the action meta, don't defer to MetaInferred
    end
    def aliases
      aliases_inferred + ['-h', '--help']
    end
    def builder
      self # not a class
    end
    def build rt
      @parent = rt ; self # assuming singleton, be careful
    end
    def invoke token=nil
      token or return @parent.help(full: true)
      b = @parent.find(token) { |o| o.on_error { |e| return emit(:error, e.message) } }
      b.respond_to?(:build) or (Module == b.class and b = NamespaceInferred.new(b)) # @duped
      ((o = b.build @parent).respond_to?(:help) ? o : DocumentorInferred.new(o, b)).help(full: true)
    end
    def visible?
      false
    end
  end
end
