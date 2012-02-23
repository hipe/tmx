require 'optparse'
require 'stringio'
require 'strscan'
require File.expand_path('../tite-color', __FILE__)
require File.expand_path('../../../skylab', __FILE__)
require 'skylab/pub-sub/emitter'


module Skylab::Porcelain
  def self.extended mod
    mod.send(:extend, ClientModuleMethods)
    mod.send(:include, ClientInstanceMethods)
    mod.send(:include, Officious::Help) unless mod.ancestors.include?(Officious::Help)
  end
  module Structuralist
    def attr_accessor_oldschool name
      method_defined?(name) or fail("#{name.inspect} must be defined in parent.")
      define_method(name) do |*a|
        case a.size ; when 0 ; super()
                      when 1 ; send("#{name}=", a.first)
                      else   ; raise ArgumentError.new("#{name} takes 0 or 1 arg.")
        end
      end
    end
  end
  class ActionDef < Struct.new(:argument_syntax, :method_name, :option_syntax, :settings)
    def argument_syntax= str
      argument_syntax and fail("won't clobber existing argument syntax")
      super(str)
    end
    def initialize
      self.settings = []
    end
    def option_syntax= b
      option_syntax and fail("for now, can't re-open option sytaces")
      super(b)
    end
    def to_hash
      Hash[* members.map { |m| [m, send(m)] }.flatten(1) ]
    end
  end
  class PorcelainModuleKnob < Struct.new(:default, :frame_settings, :runtime_instance_settings)
    extend Structuralist
    def action
      @action ||= ActionDef.new
    end
    def action!
      a = @action # nil ok
      @action = nil
      a
    end
    def default= *defaults
      1 == defaults.size && Array === defaults.first and defaults = defaults.first
      frame_settings.push(->(_){ self.default= defaults })
    end
    alias_method :default, :default= # !
    def fuzzy_match= b
      frame_settings.push(->(_){ self.fuzzy_match = b })
    end
    alias_method :fuzzy_match, :fuzzy_match= # !
    def initialize
      self.frame_settings = []
      self.runtime_instance_settings = []
    end
    def invocation_name= s
      runtime_instance_settings.push(->(_){ self.invocation_slug = s })
      s
    end
    alias_method :invocation_name, :invocation_name= # !
  end
  module Dsl
    # (This module is for wiring only.  Must be kept light outside and in.)
    def action &b
      @porcelain.action.tap { |a| a.settings.push(b) if b }
    end
    def argument_syntax str
      @porcelain.action.argument_syntax = str
    end
    def porcelain_dsl_init
      @porcelain ||= PorcelainModuleKnob.new # already set iff this is a subclass
    end
    def emits *a
      porcelain { emits(*a) }
    end
    def method_added method_name
      if defn = @porcelain.action!
        defn.method_name = method_name
        _actions_cache.cache Action.new(defn)
      end
    end
    def namespace name, *params, &block
      _actions_cache.cache Namespace.new(name, *params, &block)
    end
    def option_syntax &block
      @porcelain.action.option_syntax = block
    end
    def porcelain &block
      @porcelain.instance_eval(&block) if block_given?
      @porcelain
    end
  end
  module ClientModuleMethods
    include Dsl
    def self.extended mod
      mod.porcelain_dsl_init
    end
    def actions
      cache = _actions_cache
      ActionEnumerator.new(cache) do |yielder|
        cache.each { |act| yielder << act }
        public_instance_methods(false).select { |m| ! cache.key?(m) }.each do |method_name|
          yielder << cache.cache(Action.new(:method_name => method_name))
        end
      end
    end
    def extended mod
      fail("implement and test me (probably just call porcelain_dsl_init on the module)")
    end
    def _actions_cache
      instance_variable_defined?('@_actions_cache') and return @_actions_cache
      ancestors = self.ancestors[(self.ancestors.first == self ? 1 : 0)..-1] # singleton class does not have self as first
      klass = ancestors.detect { |a| a.class == ::Class and a.respond_to?(:_actions_cache) }
      mods = ancestors.select { |a| a.class == ::Module and a.respond_to?(:_actions_cache) }
      klass and mods -= klass.ancestors # wow it's if we are implementing ruby in ruby, how stupid
      @_actions_cache = ActionsCache.new.initiate
      [*mods, *[klass].compact].each { |anc| @_actions_cache.merge_in_duplicates_no_clobber! anc.actions }
      @_actions_cache
    end
    def inherited cls
      cls.porcelain_dsl_init
    end
  end
  class ActionsCache
    def [] k
      @hash[k].kind_of?(Symbol) ? @hash[@hash[k]] : @hash[k]
    end
    def cache action
      @hash.key?(action.name) or @order.push action.name
      @hash[action.method_name] = action.name
      @hash[action.name] = action
    end
    def each &block
      @order.each { |k| block.call(@hash[k]) }
    end
    def initiate
      @hash = {}
      @order = []
      self
    end
    def key? key
      @hash.key? key
    end
    def merge_in_duplicates_no_clobber! actions
      actions.each { |a| @hash.key?(a.name) or cache(a.duplicate) }
    end
  end
  class ActionEnumerator < Enumerator
    def initialize cache, &block
      @cache = cache
      super(&block)
    end
    def [] sym
      @cache.key?(sym) and return @cache[sym]
      detect { |a| a.name == sym }
    end
    def visible
      me = self
      self.class.new(@cache) do |yielder|
        me.each do |a|
          yielder.yield(a) if a.visible?
        end
      end
    end
  end
  class Subscriptions
    def to_proc
      orig = self
      lambda do |neue|
        orig.event_listeners.keys.each do |k|
          neue.send("on_#{k}") { |*e| orig.emit(k, *e) }
        end
      end
    end
  end
  class << Subscriptions
    alias_method :_new, :new
    def new(*names)
      Subscriptions == self or fail("hack failed")
      Class.new(Subscriptions).class_eval do
        extend ::Skylab::PubSub::Emitter
        emits :all
        names.each { |n| emits(n => :all) }
        class << self
          alias_method :new, :_new
        end
        self
      end
    end
  end
  HelpSubs      = Subscriptions.new(:default, :header, :two_col)
  ParseOptsSubs = Subscriptions.new(:syntax, :help_flagged, :push) # hack'd
  ParseSubs     = Subscriptions.new(:push, :syntax)

  class Action < Struct.new(:aliases, :argument_syntax, :method_name, :name, :option_syntax, :visible)
    extend Structuralist
    def argument_syntax
      (as = super).respond_to?(:parse_arguments) ? as :
        (self.argument_syntax = ArgumentSyntax.parse_syntax(as || ''))
    end
    def duplicate
      Action.new( :aliases         => (aliases ? aliases.dup : aliases),
                  :argument_syntax => argument_syntax.to_s, # !
                  :method_name     => method_name,
                  :option_syntax   => option_syntax.duplicate,
                  :visible         => visible)
    end
    def help(&block)
      option_syntax.help(&block)
    end
    def initialize params=nil, &block
      super(nil, nil, nil, nil, nil, true)
      ActionDef === params and params = params.to_hash
      block and params2 = self.class.define(&block).to_hash
      params && params2 and (params.merge!(params2))
      params ||= params2
      params and params.each { |k, v| send("#{k}=", v) }
    end
    def method_name= sym
      self.name ||= self.class.nameize(sym)
      super(sym)
    end
    def namespace?
      false
    end
    def option_syntax
      (os = super).respond_to?(:parse_options) ? os :
        (self.option_syntax = OptionSyntax.build(os))
    end
    def parse argv
      yield(o = ParseSubs.new)
      false == (opts = option_syntax.parse_options(argv, & o.to_proc)) and return
      b = argument_syntax.parse_arguments(argv, & o.to_proc) or return b
      # experimental sugar to avoid the client having to do their own parsing in this scenario, apparently not necessary in 1.9!
      # if opts && argument_syntax.any? && ! argument_syntax.last.glob? && argv.length < argument_syntax.length
      #  argv.concat Array.new(argument_syntax.length - argv.length) # but still it is so dodgy!
      # end
      opts and argv.push(opts)
      argv
    end
    def settings= ba
      ba.each { |b| instance_eval(&b) }
    end
    def syntax
      [name, option_syntax.to_s, argument_syntax.to_s].compact.join(' ')
    end
    def to_hash
      duplicate._to_hash
    end
    def _to_hash
      Hash[ * members.map { |k| [k, send(k)] }.flatten(1) ]
    end
    attr_accessor_oldschool :visible
    alias_method :visible?, :visible
  end
  class << Action
    def define &block
      kls = Class.new.class_eval do
        extend ClientModuleMethods
        class_eval(&block)
        self
      end
      1 == (acts = kls.actions.map{ |x| x }).size or
        raise("Block was expected to define one action. Had #{acts.size}.")
      acts.first
    end
    def nameize sym
      sym.to_s.gsub('_', '-').intern
    end
  end
  class OptionSyntax < Array
    def self.build mixed
      case mixed
      when NilClass ; new
      when Proc     ; new.push mixed
      end
    end
    def build_parser context, option_parser = nil
      option_parser ||= OptionParser.new.tap do |op|
        op.base.long['help'] = ::OptionParser::Switch::NoArgument.new do
          throw :option_action, ->(frame, action) { frame.client_instance.help(action) ; nil }
        end
      end
      each { |b| option_parser.instance_exec(context, &b) }
      option_parser
    end
    alias_method :duplicate, :dup # only as long as it's stateless
    HEADER = /\A +[^:]+:/
    def help(&block)
      empty? and return
      yield(knob = HelpSubs.new)
      renderer = r = ::OptionParser.new
      lucky_matcher = /\A(#{Regexp.escape(r.summary_indent)}.{1,#{r.summary_width}})[ ]*(.*)\z/
      renderer.banner = ''
      build_parser({}, renderer)
      lines = renderer.to_s.split("\n")
      once = false
      lines.each do |line|
        case line
        when ''            ; # we might emit this after all
        when lucky_matcher ;
                           ; once ||= (knob.emit(:header, 'options') || true)
                           ; knob.emit(:two_col, $1, $2)
        when HEADER        ; knob.emit(:header, *line.strip.split(':', 2))
        else               ; knob.emit(:default, line)
        end
      end
    end
    def parse_options argv
      empty? and ! Officious::Help::SWITCHES.include?(argv.first) and return nil
      yield(knob = ParseOptsSubs.new)
      option_parser = build_parser(context = {})
      begin
        option_parser.parse! argv
      rescue ::OptionParser::ParseError => e
        knob.emit_syntax e
        context = false
      end
      context
    end
    def to_s
      0 == count and return nil
      build_parser({}).instance_variable_get('@stack')[2].list.select{ |s| s.kind_of?(::OptionParser::Switch) }.map do |switch| # ick
        "[#{[(switch.short.first || switch.long.first), switch.arg].compact.join('')}]"
      end.join(' ')
    end
  end
  class ArgumentSyntax < Array
    def self.parse_syntax str
      new.init(str).validate
    end
    def init str
      p = StringScanner.new(str)
      until p.eos?
        p.skip(/ /)
        matched = p.scan(Parameter::REGEX) or
          raise RuntimeError.new("failed to parse: #{p.rest.inspect}#{" (after #{last.to_s.inspect})" if any?}")
        matchdata = Parameter::REGEX.match(matched)
        push Parameter.new(:matchdata => matchdata)
      end
      self
    end
    def parse_arguments argv, &block
      ArgumentParse[self, argv, &block]
    end
    def to_s
      0 == count and return nil
      join(' ')
    end
    def validate
      signature = map { |p| p.glob? ? 'G' : 'g' }.join('')
      /G.*G/ =~ signature and fail("globs cannot be used more than once (had: #{signature})")
      /\AGg/ =~ signature and fail("globs cannot occur at the beginning (had: #{signature})")
      /gGg/  =~ signature and fail("globs cannot occur in the middle (had: #{signature})")
      signature = map { |p| p.required? ? 'o' : 'O' }.join('')
      /\AOo/ =~ signature and fail("optionals cannot occur at the beginning (had: #{signature})")
      /oO+o/ =~ signature and fail("optionals cannot occur in the middle (had: #{signature})")
      self
    end
    ArgumentParse = lambda do |syntax, argv, &block|
      # (i blame Davis Frank for inspiring me to experiment with writing this like this)
      block[o = ParseSubs.new]
      o.respond_to?(:on_all) or fail("no")
      tokens = ArrayAsTokens.new(argv)
      symbols = ArrayAsTokens.new(syntax)
      nope = lambda { |msg| o.emit(:syntax, msg) ; false }
      while tokens.any?
        symbol = symbols.current or return nope["unexpected argument: #{tokens.current.inspect}"]
        tokens.advance
        symbol.glob? or symbols.advance
      end
      symbols.current and symbols.current.required? and return nope["expecting: #{Styles::e13b symbols.current}"]
      true
    end
  end
  class ArgumentSyntax::ArrayAsTokens
    def initialize arr
      @current = 0
      @length = arr.count
      @arr = arr
    end
    def advance
      @current += 1
    end
    def any?
      @current < @length
    end
    def current
      @arr[@current]
    end
  end
  class Parameter
    NAME = %r{<([_a-z]+)>}
    REGEX = %r{
           #{NAME.source} [ ]* ( \[ (?: <\1> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )?
      | \[ #{NAME.source} [ ]* ( \[ (?: <\3> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )? \]
    }x
    def glob? ; @max.nil? end
    def initialize opts
      opts.each { |k, v| send("#{k}=", v) }
    end
    def matchdata= md
      @name = (md[1] || md[3]).intern
      if md[1]
        @min = 1
        @max = md[2] ? nil : 1
      else
        @min = 0
        @max = md[4] ? nil : 1
      end
    end
    def required? ; @min > 0 ; end
    def to_s
      ellipses = @max.nil? ? " [<#{@name}>[...]]" : ''
      required? ? "<#{@name}>#{ellipses}" : "[<#{@name}>#{ellipses}]"
    end
  end

  class PorcelainInstanceKnob < Struct.new(:runtime, :runtime_instance_settings)
  end

  # .. below is invocation mechanics
  module ClientInstanceMethods
    def porcelain_init &block
      @porcelain ||= PorcelainInstanceKnob.new
      @porcelain.runtime = nil
      @porcelain.runtime_instance_settings = block
    end
    alias_method :initialize, :porcelain_init
    def invoke argv
      @porcelain.runtime = Runtime.new(argv, self, @porcelain, self.class.porcelain)
      (client, action, args = @porcelain.runtime.resolve) or return client
      client.send(action.method_name, *args)
    end
    def porcelain_runtime
      @porcelain.runtime
    end
    alias_method :runtime, :porcelain_runtime
  end

  module Styles
    include TiteColor
    extend self
    def e13b str   ; stylize str, :green          end
    def header str ; stylize str, :strong, :green end
  end


  module ArgvTokenParse
    include Styles
    def action_invalid
      issue("Invalid action: #{e13b invocation_slug}", "Expecting #{render_actions}")
      false
    end
    def argv_empty
      if default? and ! defaulted?
        argv.concat default.map(&:to_s)
        self.defaulted = true #!
      else
        argv_empty_final
      end
    end
    def argv_empty_final
      issue("Expecting #{render_actions}.")
      nil
    end
    def issue *msgs
      action = msgs.shift if msgs.first.respond_to?(:name)
      msgs.each { |s| emitter.emit(:runtime_issue, s) }
      invite action
    end
    def invite action=nil
      emitter.emit(:ui, action ?
        "Try #{e13b "#{invocation(0..-2)} #{action.name} -h"} for help." :
        "Try #{e13b "#{invocation} -h"} for help."
      )
      nil
    end
    def on_help_switch
      argv[0] = 'help' # might bite one day
    end
    def render_actions
      actions_provider or return above.render_actions # sorry
      "{#{actions_provider.actions.visible.map{ |a| e13b(a.name) }.join('|')}}"
    end
    # @return [invoker, method, args] or false/nil
    def resolve
      actions_provider or return above.resolve # sorry
      self.defaulted = false
      wtf = nil
      loop do
        argv.empty? and (b = argv_empty or return b)
        Officious::Help::SWITCHES.include?(argv.first) and (on_help_switch or return)
        /^-/ =~ argv.first and no_command
        resolve_action or return false
        wtf = catch(:option_action) do
          action.parse(argv) do |o|
            o.on_syntax { |e| emitter.emit(:syntax, e) }
            o.on_push do |frame, _| # insane sh*t happening here
              frame.argv = argv
              frame.emitter = emitter
              frame.fuzzy_match.nil? and frame.fuzzy_match = fuzzy_match
              self.above = frame
              self.argv = nil
              return frame.resolve # ! crazy crazy move
            end
          end
        end
        break
      end
      case wtf
      when Proc       ; [wtf, Action.new(:method_name => :call), [self, self.action]] # option actions
      when NilClass   ;  nil # silent!?
      when FalseClass ;
        issue(action, "usage: #{e13b "#{invocation(0..-2)} #{action.syntax}"}")
        false
      when Array      ; [client_instance, action, wtf]
      else            ; fail("wtf: #{wtf}")
      end
    end
    def resolve_action
      self.action = nil
      sym = (self.invocation_slug = (argv.shift or fail('no'))).intern
      if exact = actions_provider.actions.detect { |a| sym == a.name }
        self.action = exact
        true
      elsif fuzzy_match?
        re = /\A#{Regexp.escape invocation_slug}/
        case (found = actions_provider.actions.select { |a| re =~ a.name.to_s }).size
        when 0
          action_invalid
        when 1
          self.action = found.first
          true
        else
          issue("Ambiguous action #{e13b invocation_slug}. "<<
                  "Did you mean #{found.map{ |a| e13b(a.name) }.join(' or ')}?")
          self.action = found # be careful you idiot
          false
        end
      else
        action_invalid
      end
    end
  end

  class CallFrame < Struct.new(:above, :action, :actions_provider, :argv,
    :below, :client_instance, :default, :defaulted, :emitter, :fuzzy_match,
    :invocation_slug
  )
    include ArgvTokenParse
    def above= x
      x.below = self
      super
    end
    alias_method :defaulted?, :defaulted
    def default?
      !! default
    end
    alias_method :fuzzy_match?, :fuzzy_match
    def initialize params
      params.each { |k, v| send("#{k}=", v) }
    end
    # lots of experimenty hacky
    def invocation o=nil
      n = self
      case o
      when NilClass
        n = n.below while n.below
        r = n.invocation(StringIO.new).string
      when StringIO
        0 == o.pos or o.write(' ')
        o.write invocation_slug
        above and above.invocation_slug and above.invocation(o)
        r = o
      when Range
        n = n.below while n.below
        r = n.invocation([])[o].join(' ')
      when Array
        o.push invocation_slug
        above and above.invocation(o)
        r = o
      end
      r
    end
  end

  class Runtime < Struct.new(:stack)
    extend ::Skylab::PubSub::Emitter
    emits({
      :error         => :all,
      :info          => :all,
      :help          => :info,
      :ui            => :info,
      :usage         => :info,
      :syntax        => :info,
      :runtime_issue => :error
    })
    def actions
      stack.above.actions_provider.actions
    end
    %w(invocation render_actions resolve).each do |m| # @delegates
      define_method(m) { |*a, &b| stack.send(m, *a, &b) }
    end
    def initialize argv, client_instance, instance_defn, module_defn
      module_defn.runtime_instance_settings.each { |b| instance_eval(&b) }
      (b = instance_defn.runtime_instance_settings) and b.call(self)
      @invocation_slug ||= File.basename($PROGRAM_NAME)
      frame = CallFrame.new(:invocation_slug => @invocation_slug)
      frame.above = CallFrame.new(
        :actions_provider => client_instance.class, :argv => argv,
        :client_instance  => client_instance,       :emitter => self,
        :fuzzy_match      => true
      ).tap do |f|
        module_defn.frame_settings.each { |bb| f.instance_eval(&bb) }
      end
      self.stack = frame
    end
    attr_writer :invocation_slug
  end

  module Officious
    # name/idea borrowed from something in OptionParse (ruby std lib)
  end

  module Officious::Help
    SWITCHES = %w(-h --help)
    extend ::Skylab::Porcelain
    argument_syntax '[<action>]'
    action { visible false }
    def help action=nil
      Plumbing.new(runtime, action).invoke
    end
  end
  class Officious::Help::Plumbing < Struct.new(:runtime, :action)
    include Styles
    %w(actions emit render_actions).each do |method| # delegates
      define_method(method) { |*a, &b| runtime.send(method, *a, &b) }
    end
    def help_action
      o = action
      if String === o
        '-h' == o and o = 'help'
        o = actions[o.intern]
      end
      o or return emit(:error, "No such action #{e13b "\"#{action}\""}.  " <<
        "Try #{e13b invocation} #{render_actions} #{e13b "-h"}.")
      emit(:usage, "#{header 'usage:'} #{e13b "#{invocation} #{o.syntax}"}")
      o.help do |x|
        x.on_header { |name, content=nil| emit(:help, "#{header("#{name}:")}#{content}") }
        x.on_two_col { |a, b| emit(:help, "#{e13b a}#{b}") }
        x.on_default { |line| emit(:help, line) }
      end
    end
    def invocation
      runtime.invocation(0..-2)
    end
    def invoke
      action and return help_action
      emit(:ui, "#{header 'usage:'} #{invocation} #{render_actions} [opts] [args]")
      emit(:ui, "For help on a particular subcommand, try #{e13b "#{invocation} <subcommand> -h"}.")
    end
  end

  class << ::Skylab::Porcelain
    def namespaces
      @namespaces ||= []
    end
  end
  class NamespaceOptionSyntax
    def initialize ns_action
      @ns_action = ns_action
    end
    def parse_options args
      nil # a namespace never parses options, only a one-token name
    end
    def to_s
      nil # important
    end
  end
  class NamespaceArgumentSyntax < ArgumentSyntax
    def initialize ns_action
      @ns_action = ns_action
      init('<action> [<arg> [..]]').validate
    end
    def to_s
      @ns_action.render_actions
    end
  end
  class Namespace < Action
    def initialize name, *params, &block
      singleton_class.extend ClientModuleMethods
        # we def. want it on the sing. class b/c namespaces are not subclasses but objects
      mod = params.shift if Module === params.first
      case params.size
      when 0 ; params = { module: mod }
      when 1 ; params[:module] = mod
      else   ; raise ArgumentError.new("expected params: [module] [opts]")
      end
      mod = params.delete(:module) # !
      params[:name] = name
      # params[:method_name] ||= :invoke
      params[:option_syntax] ||= NamespaceOptionSyntax.new(self)
      params[:argument_syntax] ||= NamespaceArgumentSyntax.new(self)
      super(params, & nil) # explicitly avoid bubbling up the block
      @block = block # nil ok
      ::Skylab::Porcelain.namespaces.push self # used for loading hacks
    end
    def parse argv
      Array === (sup = super(argv)) && 1 == sup.size or return sup
      if @block
        singleton_class.class_eval(&@block)
        @block = nil
      end
      yield(ParseSubs.new).event_listeners[:push].last.call(
        CallFrame.new(
          :argv => argv,
          :action => self,
          :client_instance => self,
          :invocation_slug => sup.first,
          :actions_provider => singleton_class
        ).tap do |f|
          singleton_class.porcelain.frame_settings.each { |b| f.instance_eval(&b) }
        end
      )
      :never_see
    end
  end
end

