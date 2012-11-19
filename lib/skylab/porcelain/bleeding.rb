require_relative '..'
require_relative 'core'
require 'skylab/pub-sub/emitter'
require 'optparse'

module Skylab::Porcelain::Bleeding
  extend ::Skylab::Autoloader
  module Styles
    include ::Skylab::Porcelain::En::Methods
    include ::Skylab::Porcelain::TiteColor::Methods
    extend self
    def em(s)  ; stylize(s, :green         )   end
    def hdr(s) ; stylize(s, :strong, :green)   end
    alias_method :pre, :em
  end
  module MetaMethods
    def aliases_inferred
      [reflector.to_s.match(/[^:]+$/)[0].gsub(/(?<=[a-z])([A-Z])/) { "-#{$1}" }.downcase]
    end
    alias_method :aliases, :aliases_inferred
    def syntax
      [option_syntax.string, argument_syntax.string].compact.join(' ')
    end
  end
  module MetaInstanceMethods
    include MetaMethods
    def desc
      reflector.respond_to?(:desc) ? reflector.desc.dup : [] # do not mutate, flyweighting!
    end
    def _klass;  self.class  end
    alias_method :reflector, :_klass
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
    include MetaInstanceMethods, Styles
    def argument_syntax
      @argument_syntax ||= if reflector.respond_to?(:argument_syntax) then reflector.argument_syntax.dupe
                           else ArgumentSyntax.new(->{ reflector.instance_method(:invoke).parameters }, ->{ option_syntax.any? }) end
    end
    def bound_invocation_method
      method(:invoke)
    end
    def emit *a
      if ! @parent
        fail("WHERE IS PARENT IN THIS #{self.class}:\n#{self.inspect}") # @todo
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
    attr_accessor :parent
    def parameters ; argument_syntax.parameters end # @delegates_to
    def program_name
      "#{@parent.program_name} #{aliases.first}"
    end
    def resolve argv # mutates argv
      args = [] # the arguments that are actually passed to the method call
      ok = option_syntax.parse!(argv, args, self)
      if ok
        meth = argument_syntax.parse!(argv, args, self)
        if meth
          [meth, args]
        else
          help
        end
      else
        false == ok ? help : nil
      end
    end
  end
  module ActionKlassInstanceMethods
    include ActionInstanceMethods
    alias_method :builder, :_klass
  end
  module ActionModuleMethods
    include MetaMethods
    def self.extended klass
      klass.send(:include, ActionKlassInstanceMethods)
    end
    def argument_syntax
      @argument_syntax ||= ArgumentSyntax.new(->{ instance_method(:invoke).parameters }, ->{ option_syntax.any? })
    end
    def build parent
      o = new
      o.parent = parent
      o
    end
    def desc *a
      instance_exec(*a, &(redef = ->(*aa) do
        _desc = aa.flatten ; singleton_class.send(:undef_method, :desc) # so no warnings
        singleton_class.send(:define_method, :desc) do |*aaa|
          (aaa.any? or ((@desc ||= nil).nil? and true == (@desc = true))) ? instance_exec(* (_desc + aaa), &redef) : _desc
        end
        self.desc
      end))
    end
    def option_syntax &defn
      option_syntax_class(os = option_syntax_class.build)
      os.define!(&defn) if block_given?
      os
    end
    def option_syntax_class k=nil
      k.nil? ? OptionSyntax : instance_exec(k, &(redef = ->(k2) {
        undef_method(:option_syntax_class)
        define_method(:option_syntax_class) { k2 }
        singleton_class.send(:undef_method, :option_syntax_class)
        singleton_class.send(:define_method, :option_syntax_class) { |k3 = nil| k3.nil? ? k2 : instance_exec(k3, &redef) }
      }))
    end
    def _self;   self        end
    alias_method :reflector, :_self
    def summary &block
      _use_block = block || ->() { (desc || [])[0..1] }
      instance_exec(_use_block, &(redef = ->(b2) do
        singleton_class.send(:define_method, :summary) do |&b3|
          b3 ? instance_exec(b3, &redef) : instance_exec(&b2)
        end
      end))
      block or summary
    end
  end
  ON_FIND = ::Skylab::PubSub::Emitter.new(:error, ambiguous: :error, not_found: :error, not_provided: :error)
  module NamespaceInstanceMethods
    include ActionInstanceMethods
    def fetch token, &not_found
      b = fetch_builder(token, &not_found) or return b
      (o = b.respond_to?(:build) ? b.build(self) : b.new).respond_to?(:resolve) ? o : RuntimeInferred.new(self, o, b)
    end
    def fetch_builder token, &not_found
      m = find(token) { |o| o.on_error { |e| return (not_found || ->(er) { raise KeyError.new(e.message) } ).call(e) } }
      (! m.respond_to?(:build) && m.kind_of?(::Module) && ! m.kind_of?(::Class)) ? NamespaceInferred.new(m) : m
    end
    def find token, &error
      e = ON_FIND.new(error) ; matched = [] ; builder = nil # resolve the match now! (flyweighting)
      token or return e.emit(:not_provided, "expecting #{syntax}")
      matcher = /^#{Regexp.escape(token)}/
      actions.names.each do |act|
        first_match = act.aliases.grep(matcher).reduce do |_first_match, name|
          name == token and return act.builder # first whole match always wins
          _first_match # we only want any one of these per action
        end and begin
          matched.push(first_match) ; builder = act.respond_to?(:builder) ? act.builder : act
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
      fetch(argv.shift) { |e| return help(message: e.message, syntax: false) }.resolve(argv)
    end
    def syntax
      "{#{ actions.names.visible.map { |a| pre a.aliases.first } * '|' }}"
    end
  end
  module NamespaceModuleMethods
    include ActionModuleMethods
    def build parent
      NamespaceInferred.new(self).build(parent)
    end
  end
  class ActionEnumerator < ::Enumerator
    singleton_class.send(:alias_method, :[], :new)
    def initialize *a, &b
      @block = if a.length > 0 then
        block_given? and raise ArgumentError.new("can't have both block and args")
        init(*a) or raise ArgumentError.new("init() block must return a Proc")
      else
        b or raise ArgumentError("block must be given if args are not")
      end
      super(&@block)
    end
    def filter &b
      self.class.new { |y| each { |*a| b.call(y, *a) } }
    end
    def _self   ; self                                                   end
    def visible ; filter { |y, a| y << a if a.visible? }                 end
  end
  class Actions < ActionEnumerator
    def init *a ; ->(y) { a.each { |e| e.each { |o| y << o } } } end
    alias_method :helps, :_self # hook for stubbing
    alias_method :names, :_self # hook for stubbing
  end
  class Constants < ActionEnumerator
    def init mod
      flyweight = nil
      ->(y) do
        mod.constants.each do |const|
          y << ((m = mod.const_get(const)).respond_to?(:action_meta) ?
            m.action_meta : (flyweight ||= MetaInferred.new).set!(m))
        end
      end
    end
  end
  class ArgumentSyntax < Struct.new(:parameters_block, :takes_options_block)
    def [] idx
      string.split(' ')[idx] or "<arg#{idx + 1}>"  # @hack
    end
    def define! s
      @string = s
    end
    alias_method :dupe, :dup # careful!
    def parameters ; parameters_block.call end
    def parse! argv, args, runtime # @duck bound_invocation_method, emit
      meth = runtime.bound_invocation_method
      parameters = takes_options? ? meth.parameters[0..-2] : meth.parameters
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
      (@string ||= nil) and return @string
      parameters[0..(takes_options? ? -2 : -1)].map do |p|
        a, b = case p.first
               when :req  ;
               when :opt  ; %w([ ])
               when :rest ; %w([ [..]])
               else       ; fail("not expecting this token: #{p.first.inspect}")
               end
        "#{a}<#{p.last}>#{b}"
      end.join(' ')
    end
    def takes_options?
      takes_options_block.call
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
    extend ActionModuleMethods
    include NamespaceInstanceMethods
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
  class MetaInferred
    include MetaInstanceMethods
    attr_reader :reflector
    alias_method :builder, :reflector
    def initialize # @todo make less of these
    end
    def set! reflector # geared towards flyweighting
      @reflector = reflector ; self
    end
  end
  class DocumentorInferred < MetaInferred
    include ActionInstanceMethods
    def initialize parent, reflector
      (@parent = parent).respond_to?(:emit) or fail("emitter?") # @todo might rename all of these to "runtime"
      set!(reflector)
    end
    def syntax # tricky: we are using this class IFF we don't have options
      ArgumentSyntax.new(->{ @reflector.instance_method(:invoke).parameters }, -> { false }).string
    end
  end
  class RuntimeInferred < DocumentorInferred
    def initialize parent, built, builder
      super(parent, builder)
      @bound_invocation_method = built.method(:invoke)
    end
    attr_reader :bound_invocation_method
  end
  class NamespaceInferred
    include NamespaceInstanceMethods
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
  module Officious
    def self.actions
      Constants[self]
    end
  end
  class Officious::Help
    extend ActionModuleMethods
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
      o = (b = @parent.fetch_builder(token) { |e| return emit(:error, e.message) }).respond_to?(:build) ? b.build(@parent) : b.new
      (o.respond_to?(:help) ? o : DocumentorInferred.new(@parent, b)).help(full: true) # 'o' gets thrown away sometimes
    end
    def visible?
      false
    end
  end
end
