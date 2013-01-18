require_relative 'core'
require 'optparse'
require 'stringio'
require 'strscan'
require 'skylab/pub-sub/emitter'

# @todo this should either be renamed "dsl" or moved into the toplevel porcelain.rb

module Skylab::Porcelain
  @namespaces = []
  class << self
    def extended mod
      mod.send(:extend, ClientModuleMethods)
      mod.send(:include, ClientInstanceMethods)
      mod.send(:include, Officious::Help) unless mod.ancestors.include?(Officious::Help)
    end
    attr_reader :namespaces
  end
  module Structuralist
    def attr_accessor_oldschool name
      define_method(name) do |*a|
        case a.size ; when 0 ; super()
                      when 1 ; send("#{name}=", a.first)
                      else   ; raise ArgumentError.new("#{name} takes 0 or 1 arg.")
        end
      end
    end
    def list_accessor_oldschool name
      define_method(name) do |*a|
        val = super()
        0 == a.size and return val
        (val or self.send("#{name}=", [])).concat a.flatten
      end
    end
  end
  module Aliasist
    extend Structuralist
    list_accessor_oldschool :aliases
    def alias name
      aliases name
    end
  end
  module Descriptionist
    extend Structuralist
    list_accessor_oldschool :description
    alias_method :desc, :description
    alias_method :description_lines, :description # temporary compat until after 049.500
  end
  class ActionDef < Struct.new(:aliases, :argument_syntax, :description,
    :method_name, :option_syntax, :settings
  )
    include Descriptionist, Aliasist
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
  class PorcelainModuleKnob < Struct.new(:aliases, :client_module, :default,
    :description, :frame_settings, :runtime, :runtime_instance_settings
  )
    include Descriptionist, Aliasist
    def action
      @action ||= ActionDef.new
    end
    def action?
      @action
    end
    def action!
      a = @action # nil ok
      @action = nil
      a
    end
    attr_accessor :actionable
    alias_method :actionable?, :actionable
    def build_client_instance runtime, slug
      client_module.build_client(runtime, slug)
    end
    def default= *defaults
      1 == defaults.size && Array === defaults.first and defaults = defaults.first
      frame_settings.push(->(_){ self.default= defaults })
    end
    alias_method :default, :default= # !
    def default_summary_lines
      a = client_module.actions.map { |o| Styles::e13b o.action_name }
      ["child command#{'s' if a.length != 1}: {#{a * '|'}}"]
    end
    def emits(*a)
      runtime.definition_blocks.push(->(_) { emits(*a) })
    end
    def fuzzy_match= b
      frame_settings.push(->(_){ self.fuzzy_match = b })
    end
    alias_method :fuzzy_match, :fuzzy_match= # !
    def initialize client_module
      @action = nil
      @actionable = true
      super(nil, client_module, nil, nil, [], RuntimeModuleKnob.new, [])
    end
    def instance_method_visibility= visibility
      case visibility
      when :public              ; self.actionable = true
      when :protected, :private ; self.actionable = false
      else                      ; fail("unexpected value: #{visibility.inspect}")
      end
      visibility
    end
    def invocation_name= s
      runtime_instance_settings.push(->(_){ self.invocation_slug = s })
      s
    end
    alias_method :invocation_name, :invocation_name= # !
    def summary
      desc or default_summary_lines
    end
  end
  class RuntimeModuleKnob < Struct.new(:definition_blocks)
    def initialize
      super([])
    end
  end
  # @todo change this to DSL from Dsl (per convention, near rspec)
  module Dsl
    # (This module is for wiring only.  Must be kept light outside and in.)
    def action &b
      @porcelain.action.tap { |a| a.settings.push(b) if b }
    end
    def argument_syntax str
      @porcelain.action.argument_syntax = str
    end
    def desc *a
      @porcelain.action.desc(*a)
    end
    def inactionable
      @porcelain.actionable = false
    end
    def porcelain_dsl_init
      unless instance_variable_defined?('@porcelain') and @porcelain
        @porcelain = PorcelainModuleKnob.new(self) # already set iff this is a subclass
        [:private, :protected, :public].each do |viz|
          singleton_class.send(:alias_method, "#{viz}_before_porcelain", viz)
          singleton_class.send(:define_method, viz) do |*a|
            @porcelain.instance_method_visibility = viz
            send("#{viz}_before_porcelain", *a)
          end
        end
      end
    end
    def method_added method_name
      if @porcelain.actionable?
        @porcelain.action? or @porcelain.action
        defn = @porcelain.action!
        defn.method_name = method_name
        _actions_cache.cache Action.new(defn, instance_method(method_name))
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
      end
    end
    def build_client runtime, slug
      client = new do |rt|
        rt.invocation_slug = slug
        client.wire! rt, runtime # it must die, all of it.
      end
      client.porcelain.runtime = runtime
      client
    end
    def extended mod
      fail("implement and test me (probably just call porcelain_dsl_init on the module)")
    end
    # @todo merge actions cache and actions enumerator !?
    def _actions_cache
      @_actions_cache ||= ActionsCache.new.initiate
      @_actions_cache.tap { |o| o.merge_new_ancestor_actions!(self) } # every time
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
      @hash.key?(action.action_name) or @order.push action.action_name
      @hash[action.method_name] = action.action_name
      @hash[action.action_name] = action
    end
    def each &block
      @order.each { |k| block.call(@hash[k]) }
    end
    def initiate
      @hash = {}
      @order = []
      @seen_ancestors = []
      self
    end
    def key? key
      @hash.key? key
    end
    def merge! actions
      actions.each do |action|
        if @hash.key?(action.action_name)
          @hash[action.action_name].merge!(action)
        else
          cache action.duplicate
        end
      end
    end
    def merge_new_ancestor_actions! selv
      ancestors = selv.ancestors
      (ancestors -= @seen_ancestors).empty? and return
      @seen_ancestors.concat ancestors
      ancestors.first == selv and ancestors.shift # singleton classes do not include themselves in ancestor chain
      klass = ancestors.detect { |a| a.class == ::Class and a.respond_to?(:_actions_cache) }
      mods = ancestors.select { |a| a.class == ::Module and a.respond_to?(:_actions_cache) }
      klass and mods -= klass.ancestors # wow it's if we are implementing ruby in ruby, how stupid
      [*mods, *[klass].compact].each do |anc|
        merge! anc.actions
      end
      true
    end
  end
  class ActionEnumerator < Enumerator
    def initialize cache, &block
      @cache = cache
      super(&block)
    end
    def [] sym
      @cache.key?(sym) and return @cache[sym]
      detect { |a| a.action_name == sym }
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
        public :emit # [#ps-002] (this is just like something over there)
        public :event_listeners # shoehorn legacy bad design into design imprv.
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

  class Action < Struct.new(:aliases, :argument_syntax,
    :argument_syntax_inferred, :description, :method_name, :action_name, :option_syntax,
    :unbound_method, :visible
  )
    extend Structuralist
    include Descriptionist, Aliasist # namespace objects use aliases in themselves explicitly below
    def argument_syntax
      (as = super).respond_to?(:parse_arguments) ? as :
        (self.argument_syntax = ArgumentSyntax.parse_syntax(as || _argument_syntax_inferred))
    end
    def _argument_syntax_inferred
      self.argument_syntax_inferred = true
      arr = []
      if 0 > (a = unbound_method.arity)
        arr.push '[<arg> [..]]'
        a = (a * -1 - 1)
      end
      if option_syntax.any?
        a = [0, a - 1].max
      end
      arr[0, 0] = (0...a).map { |i| "<arg#{i + 1}>" }
      arr * ' '
    end
    alias_method :argument_syntax_inferred?, :argument_syntax_inferred
    def duplicate
      Action.new( :aliases         => (aliases     ? aliases.dup     : nil),
                  :argument_syntax => argument_syntax.to_str, # !
                  :description     => (description ? description.dup : nil),
                  :method_name     => method_name,
                  :option_syntax   => option_syntax.duplicate,
                  :unbound_method  => unbound_method, # sketchy / experimental
                  :visible         => visible)
    end
    def help(&block)
      if description
        yield(o = HelpSubs.new)
        if 1 == description.size
          o.emit(:header, 'description', description.first)
        else
          o.emit(:header, 'description')
          description.each { |s| o.emit(:default, s) }
        end
      end
      option_syntax.help(&block)
    end
    def initialize params=nil, unbound = nil, &block
      super(nil, nil, false, nil, nil, nil, nil, unbound, true)
      ActionDef === params and params = params.to_hash
      block and params2 = self.class.define(&block).to_hash
      params && params2 and (params.merge!(params2))
      params ||= params2
      params and params.each { |k, v| send("#{k}=", v) }
    end
    def merge! action
      # @todo we just totally ignore the very idea of this for now
    end
    def method_name= sym
      self.action_name ||= self.class.nameize(sym)
      super(sym)
    end
    def name_syntax
      aliases or return action_name
      "{#{ [action_name, *aliases] * '|' }}"
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
      false == (opts = option_syntax.parse_options(argv, & o.to_proc)) and return false # !
      b = argument_syntax.parse_arguments(argv, & o.to_proc) or return b
      # experimental sugar to avoid the client having to do their own parsing in this scenario, apparently not necessary in 1.9!
      # if opts && argument_syntax.any? && ! argument_syntax.last.glob? && argv.length < argument_syntax.length
      #  argv.concat Array.new(argument_syntax.length - argv.length) # but still it is so dodgy!
      # end
      opts and argv.push(opts)
      [ nil, self, argv ] # [ receiver, action_ref, args ]
    end
    def settings= ba
      ba.each { |b| instance_eval(&b) }
    end
    def syntax
      [name_syntax, option_syntax.to_str, argument_syntax.to_str].compact.join(' ')
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
      if ! option_parser
        op = ::OptionParser.new
        op.base.long['help'] = ::OptionParser::Switch::NoArgument.new do
          throw :option_action, ->(frame, action) { frame.client_instance.help(action) ; nil }
        end

        op.banner = ''            # without this you hiccup 2 usages, the latter
                                  # being an unstylied one from o.p
        option_parser = op
      end
      each { |b| option_parser.instance_exec(context, &b) }
      option_parser
    end
    alias_method :duplicate, :dup # only as long as it's stateless
    HEADER = /\A +[^:]+:/
    def help(&block)
      empty? and return
      yield(knob = HelpSubs.new)
      renderer = r = option_parser
      lucky_matcher = /\A(#{Regexp.escape(r.summary_indent)}.{1,#{r.summary_width}})[ ]*(.*)\z/
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
    def option_parser
      @option_parser ||= begin
        op = build_parser(@context = {})
        @rebuild = @context.any?
        op
      end
    end
    def option_parser_parse! argv
      if @option_parser
        if @rebuild
          @option_parser = nil
        else
          @context.clear
        end
      end
      option_parser.parse! argv
      if @rebuild
        @context
      else
        @context.dup
      end
    end
    def parse_options argv
      empty? and ! Officious::Help::SWITCHES.include?(argv.first) and return nil
      yield(knob = ParseOptsSubs.new)
      begin
        context = option_parser_parse! argv
      rescue ::OptionParser::ParseError => e
        knob.emit(:syntax, e)
        context = false
      end
      context
    end
    def to_str
      0 == count and return nil
      option_parser.instance_variable_get('@stack')[2].list.select{ |s| s.kind_of?(::OptionParser::Switch) }.map do |switch| # ick
        "[#{[(switch.short.first || switch.long.first), switch.arg].compact.join('')}]"
      end.join(' ')
    end
  protected
    def initialize *a
      super
      @option_parser = nil
    end
  end
  # @todo see if we can get this whole class to go away in lieu of the improved reflection of ruby 1.9
  class ArgumentSyntax < Array
    def self.parse_syntax str
      new.init(str).validate
    end
    def init str
      p = StringScanner.new(str)
      until p.eos?
        p.skip(/ /)
        matched = p.scan(Parameter::REGEX) or
          raise RuntimeError.new("failed to parse: #{p.rest.inspect}#{" (after #{last.to_str.inspect})" if any?}")
        matchdata = Parameter::REGEX.match(matched)
        push Parameter.new(:matchdata => matchdata)
      end
      self
    end
    def parse_arguments argv, &block
      ArgumentParse[self, argv, &block]
    end
    def to_str
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
      touched = false
      while tokens.any?
        symbol = symbols.current or return nope["unexpected argument: #{tokens.current.inspect}"]
        tokens.advance
        if symbol.glob?
          touched = true
        else
          symbols.advance
        end
      end
      (s = symbols.current) and s.required? and (!s.glob? or !touched) and
        return nope["expecting: #{Styles::e13b s.to_str}"]
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
    NAME = %r{<([-_a-z][-_a-z0-9]*)>}
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
    def to_str
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
      @porcelain.runtime_instance_settings = block ||
        ->(o) { o.on_all { |e| $stderr.puts " * #{e}" } } # an ugly default to make you want to change it
    end
    def help_frame
      @porcelain.runtime.stack.top
    end
    alias_method :initialize, :porcelain_init
    def invoke argv
      res = nil
      begin
        @porcelain.runtime =
          Runtime.new argv, self, @porcelain, self.class.porcelain
        client, meth, args = @porcelain.runtime.resolve
        client or break( res = client )
        meth = meth.method_name if ! ( ::Symbol === meth )
        res = client.send meth, *args
      end while nil
      res
    end
    attr_reader :porcelain
    def porcelain_runtime
      @porcelain.runtime
    end
    alias_method :runtime, :porcelain_runtime
  end

  module Styles
    include Headless::CLI::Stylize::Methods
    extend self
    def e13b str   ; stylize str, :green          end
    def header str ; stylize str, :strong, :green end
  end


  module ArgvTokenParse
    include Styles
    def actions
      actions_provider.actions
    end
    def action_invalid
      issue("Invalid action: #{e13b invocation_slug}", "Expecting #{render_actions}")
      nil
    end
    def argv_empty
      if default? and ! defaulted?
        argv[0, 0] = default.map(&:to_s)
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
      action = msgs.shift if msgs.first.respond_to?(:action_name)
      msgs.each { |s| emitter.emit(:runtime_issue, s) }
      invite action
      nil
    end
    def invite action=nil
      emitter.emit(:ui, action ?
        "Try #{e13b "#{invocation(0..-2)} #{action.action_name} -h"} for help." :
        "Try #{e13b "#{invocation(0..-2)} -h"} for help."
      )
      nil
    end
    alias_method :no_command, :argv_empty # for now!
    def on_help_switch
      argv[0] = 'help' # might bite one day
      true # stay
    end
    def render_actions
      actions_provider or return above.render_actions # sorry
      "{#{actions_provider.actions.visible.map{ |a| e13b(a.action_name) }.join('|')}}"
    end
    def render_usage action
      "#{header 'usage:'} #{e13b "#{invocation(0..-2)} #{action.syntax}"}"
    end

    # @return [invoker, method, args] or false/nil
    # (this is a bunch of legacy spaghetti, some of which i had to derp with)
    def resolve
      res = nil
      begin
        actions_provider or break( res = above.resolve )
        self.defaulted = false
        if argv.empty?
          r = argv_empty or break( res = r )
        end
        if Officious::Help::SWITCHES.include? argv.first
          r = on_help_switch or break( res = r )
        end
        if '-' == argv.first[0]
          r = no_command or break( res = r )
        end
        r = resolve_action or break( res = r )
        stay = true
        wtf = catch :option_action do
          action.parse argv do |o|
            o.on_syntax do |e|
              emitter.emit :syntax, e
            end
            o.on_push do |frame, _|
              frame.argv = argv
              frame.emitter = emitter
              if frame.fuzzy_match.nil?
                frame.fuzzy_match = fuzzy_match
              end
              self.above = frame
              self.argv = nil
              res = frame.resolve
              stay = false
            end
          end
        end
        stay or break
        if wtf
          case wtf
          when ::Array
            wtf[0] ||= client_instance # res = [ client_instance, action, wtf ]
            res = wtf # experimentallly we want a total divorce
          when ::Proc
            res = [ wtf, Action.new(method_name: :call), [ self, self.action ] ]
          else
            fail "wtf: #{ wtf }"
          end
        elsif false == wtf
          issue action, render_usage( action )
        end
      end while nil
      res
    end

    def resolve_action
      res = self.action = nil
      str = self.invocation_slug = argv.shift or fail 'sanity'
      sym = invocation_slug.intern

      if actions_provider.respond_to? :call
        self.actions_provider = actions_provider.call # collapse - load
        # this can offer considerable savings when compared to other brands
        # i mean this can allow us to lazy load possibly dozens of files,
        # possibly using a different framework entirely
      end

      if actions_provider.respond_to? :collapse_intermediate_action
        self.actions_provider =
          actions_provider.collapse_intermediate_action self
        # collapse the box (branch) action itself into a live, wired action.
        # this way leaf actions that need a live parent action can have one.
        # (the leaf would grab this in its `collapse_action` impl.)
      end

      exact = actions_provider.actions.detect do |a|
        if sym == a.action_name
          b = true
        elsif a.aliases
          b = a.aliases.include? str
        end
        b
      end
      if exact
        action_resolved exact
        res = true
      elsif fuzzy_match?
        rx = /\A#{ ::Regexp.escape invocation_slug }/
        found = actions_provider.actions.select do |a|
          yes = nil
          if rx =~ a.action_name.to_s
            yes = true
          elsif a.aliases
            yes = a.aliases.index { |s| rx =~ s }
          end
          yes
        end
        case found.length
        when 0
          res = action_invalid
        when 1
          action_resolved found.first
          res = true
        else
          issue("Ambiguous action #{e13b invocation_slug}. "<<
                  "Did you mean #{found.map{ |a| e13b(a.action_name) }.join(' or ')}?")
          self.action = found # be careful you idiot
          res = nil
        end
      else
        res = action_invalid
      end
      res
    end
  protected
    def action_resolved x
      if x.respond_to? :collapse_action # then it might be a help emissary or
        x = x.collapse_action self      # a class from the future. this is a
      end                               # a forward-fitting future compat hack
      self.action = x
      nil
    end
  end

  class CallFrame < Struct.new(:above, :action, :actions_provider, :argv,
    :below, :get_client_instance, :default, :defaulted, :emitter, :fuzzy_match,
    :invocation_slug
  )
    include ArgvTokenParse
    def above= x
      x.below = self
      super
    end
    def client_instance
      @client_instance ||= get_client_instance.call
    end
    attr_writer :client_instance
    alias_method :defaulted?, :defaulted
    def default?
      !! default
    end
    def emit(*a)
      emitter.emit(*a)
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
    def top
      above ? above.top : self
    end
  end

  class Runtime < Struct.new(:stack)
    extend ::Skylab::PubSub::Emitter
    emits({
      :error         => :all,
      :info          => :all,
      :help          => :info,
      :payload       => :all,
      :ui            => :info,
      :usage         => :info,
      :syntax        => :info,
      :runtime_issue => :error
    })

    public :emit # shoehorn legacy bad design inside better design [#ps-002]

    alias_method :porcelain_original_event_class, :event_class # compat pub sub
    attr_writer :event_class
    def event_class
      @event_class or porcelain_original_event_class
    end
    %w(invocation render_actions resolve).each do |m| # @delegates @todo:#100.200.1
      define_method(m) { |*a, &b| stack.send(m, *a, &b) }
    end
    def initialize argv, client_instance, instance_defn, module_defn
      module_defn.runtime.definition_blocks.each { |b| singleton_class.module_eval(&b) }
      module_defn.runtime_instance_settings.each { |b| instance_eval(&b) }
      (b = instance_defn.runtime_instance_settings) and b.call(self)
      @event_class = nil
      @invocation_slug ||= File.basename($PROGRAM_NAME)
      self.stack = -> do
        frame = CallFrame.new invocation_slug: @invocation_slug
        frame.above = -> do
          fr = CallFrame.new actions_provider: client_instance.class,
                                         argv: argv,
                              client_instance: client_instance,
                                      emitter: self,
                                  fuzzy_match: true
          module_defn.frame_settings.each { |bb| fr.instance_eval(& bb ) }
          fr
        end.call
        frame
      end.call
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
      help_frame or raise 'need frame.'
      subclient = Plumbing.new help_frame, action
      subclient.invoke
    end
  end

  class Officious::Help::Plumbing < ::Struct.new :frame, :action_ref
    include Styles

    def actions
      frame.actions
    end

    def emit name, *payload
      frame.emit name, *payload
    end

    # had to rescue this. didn't want to
    def help_action
      res = nil
      begin
        action_ref = self.action_ref
        if ::String === action_ref
          action_ref = 'help' if '-h' == action_ref
          action_struct = actions[ action_ref.intern ]
        else
          action_struct = action_ref
        end
        if ! action_struct
          emit :error, "No such action #{ e13b "\"#{ action_ref }\"" }. #{
          }Try #{ e13b invocation } #{ render_actions } #{ e13b '-h' }."
          break
        end
        s = frame.render_usage action_struct
        emit :usage, s
        action_struct.help do |o|
          o.on_header do |name, content|
            emit :help, "#{ header "#{ name }:" }#{ " #{ content }" if content}"
          end
          o.on_two_col do |a, b|
            emit :help, "#{ e13b a }#{ b }"
          end
          o.on_default do |line|
            emit :help, line
          end
        end
      end while nil
      res
    end

    def invocation *x
      frame.invocation(* x)
    end

    def invoke
      if action_ref
        help_action
      else
        emit :ui, "#{ header 'usage:' } #{ invocation( 0 .. -2 ) } #{
        }#{ render_actions } [opts] [args]"
        emit :ui, "For help on a particular subcommand, try #{
        }#{ e13b "#{ invocation(0..-2) } <subcommand> -h" }."
      end
      nil
    end

    def render_actions
      frame.render_actions
    end

  protected

    def initialize frame, action_ref
      frame or raise ::ArgumentError.new "need frame."
      super
    end
  end

  class << ::Skylab::Porcelain
  end
  class NamespaceOptionSyntax < OptionSyntax
    def initialize ns_action
      @ns_action = ns_action
    end
    def parse_options args
      nil # a namespace never parses options, only a one-token name
    end
    def to_str
      nil # important
    end
  end
  class NamespaceArgumentSyntax < ArgumentSyntax
    def initialize namespace_instance
      @namespace_instance = namespace_instance
      init('<action> [<arg> [..]]').validate
    end
    def to_s
      @namespace_instance.frame.render_actions
    end
  end
  module NamespaceAsClientInstanceAdapter
    def help_frame
      frame
    end
  end
  class Namespace < Action
    def actions_provider
      case @mode
      when :inline   ; inflate! if @block
                     ; singleton_class
      when :external ; external_module
      end
    end
    attr_accessor :client_instance
    def get_ns_client slug
      case @mode
      when :inline
        @porcelain or porcelain_init # i want it all to go away
        @porcelain.runtime = @frame.emitter
        self
      when :external
        external_module.porcelain.build_client_instance(@frame.emitter, slug) # @todo: during:#100.100.400
      else
        fail('no')
      end
    end
    # @todo during:#100.200 for_run <=> build_client_instance
    def for_run ui, slug # compat
      if @external_module.respond_to?(:porcelain)
        @external_module.porcelain.build_client_instance(ui, slug)
      else
        @external_module.new(out: ui.out, err: ui.err, program_name: slug)
      end
    end
    def inflate!
      singleton_class.class_eval(&@block)
      @block = nil
    end

                                  # (legacy spaghetti - make this work for tons
                                  # of different generations of other nerks)
    resolve_initialization_parameters = -> name, params, block do
      if ::Hash === params.first
        param_h = params.shift
        external_module_ref = param_h.delete :module # if any
      else
        param_h = { }
        if ::Module === params.first
          external_module_ref = params.shift
        elsif params.first.respond_to? :call
          external_module_ref = params.shift
        end
      end
      if params.length.nonzero?
        raise ::ArgumentError.new "sorry - overloaded method signature fail"
      end
      if external_module_ref && block
        raise ::ArgumentError.new "can't have namespace defined in both #{
          }block and module"
      end
      param_h[:action_name] = name
      # param_h[:method_name] ||= :invoke
      param_h[:option_syntax]   ||= NamespaceOptionSyntax.new   self
      param_h[:argument_syntax] ||= NamespaceArgumentSyntax.new self
      [block, external_module_ref, param_h]
    end

    define_method :initialize do |name, *params, &block|
      @block, external_module_ref, param_h =
        resolve_initialization_parameters[ name, params, block ]
      name = params = block = nil
      if external_module_ref
        @mode = :external
        if ::Module === external_module_ref
          @external_module = external_module_ref
          @external_module_ref = nil
        else
          @external_module = nil
          @external_module_ref = external_module_ref
        end
      else
        @mode = :inline
      end
      @porcelain = nil
      super( param_h, & nil ) ; param_h = nil       # do not bubble the block up
      if :external == @mode
        if @external_module && @external_module.respond_to?( :porcelain )
          if @external_module.porcelain.aliases
            aliases(* @external_module.porcelain.aliases)
          end
        end
      else # :inline
        class << self
          # we want all this on the sing. class because this object is not a subclass but an instance
          extend ClientModuleMethods
          include ClientInstanceMethods
          prev = porcelain.actionable
          porcelain.actionable = false # else it actually pings us for the below definition
          def singleton_method_added metho
            singleton_class.method_added metho # yes wtf. talk to matz ^_^
          end
          porcelain.actionable = prev
        end
        class << self
          include Officious::Help
          include NamespaceAsClientInstanceAdapter # must come after above
        end
      end
      # porcelain_init
      ::Skylab::Porcelain.namespaces.push self # used for loading hacks
    end

    attr_reader :frame

    def parse argv
      inflate! if @block
      slug = argv.first
      @frame = CallFrame.new(
        :argv => argv,
        :action => self,
        :get_client_instance => -> do
          get_ns_client slug
        end,
        :invocation_slug => slug,
        :actions_provider => actions_provider
      )
      if :inline == @mode
        singleton_class.porcelain.frame_settings.each { |b| f.instance_eval(&b) }
      end
      failed = super(argv) or return failed
      # the grammar for namespaces takes no options and does not change argv
      yield(ParseSubs.new).event_listeners[:push].last.call(@frame)
      :never_see
    end

    def summary
      case @mode
      when :external
        if @external_module.respond_to?(:porcelain)
          @external_module.porcelain.summary
        else
          a = @external_module.command_tree.map(&:action_name) # watch the world burn
          ["child commandz: {#{a.join('|')}}"]
        end
      else              ;  fail("implement me")
      end
    end

  protected

    def external_module
      @external_module ||= begin
        em = @external_module_ref.call
        @external_module_ref = nil
        em
      end
    end
  end
end
