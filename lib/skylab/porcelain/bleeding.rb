require_relative 'core'
require 'skylab/headless/core' # here til  all.rb is away, Headless::NLP::EN::M.
require 'skylab/pub-sub/core'
require 'optparse'

module Skylab::Porcelain::Bleeding
  extend ::Skylab::Autoloader

  Headless = ::Skylab::Headless
  MetaHell = ::Skylab::MetaHell
  Porcelain = ::Skylab::Porcelain # #hiccup
  PubSub = ::Skylab::PubSub

  module Styles
    include Headless::NLP::EN::Methods
    include Headless::CLI::Stylize::Methods
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
      # (note this used to be <= 2 lines of desc, now it is 1..)
      res = nil
      desc = self.desc
      desc or fail "sanity - no generated desc?"
      if desc.length > 1
        res = [ "#{ desc.first }.." ]
      else
        res = desc
      end
      res
    end

    def visible?
      true
    end
  end


  module Action
    def self.extended klass # #pattern [#sl-111]
      klass.extend Action::ModuleMethods
      klass.send :include, ActionKlassInstanceMethods
    end
  end

#  amusing #eye-blood :
#    @argument_syntax ||= if reflector.respond_to?(:argument_syntax) then reflector.argument_syntax.dupe
#                         else ArgumentSyntax.new(->{ reflector.instance_method(:invoke).parameters }, ->{ option_syntax.any? }) end

  module ActionInstanceMethods

    include MetaInstanceMethods, Styles

    def argument_syntax
      @argument_syntax ||= begin
        if reflector.respond_to? :argument_syntax
          o = reflector.argument_syntax.dupe
        else
          o = ArgumentSyntax.new(
            ->{ reflector.unbound_invocation_method.parameters },
            ->{ option_syntax.any? }
          )
        end
        o
      end
    end

    def bound_invocation_method
      method :invoke
    end

    def emit *a
      if ! parent
        fail "sanity - where is parent in this #{self.class}:\n#{self.inspect}"
      end
      parent.emit(*a)
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
      if option_syntax.any?
        option_syntax.help -> line { emit :help, line }
      end
      nil
    end

    def help_usage o
      emit :help, "#{ hdr 'usage:' } #{ program_name } #{ syntax }".strip
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
      "#{ parent.program_name } #{ aliases.first}"
    end

    def resolve argv # mutates argv
      r = nil
      begin
        args = [] # the arguments that are actually passed to the method call
        r = option_syntax.parse( argv, args,
          ->   { help full: true       ; nil   }, # nil = no more help
          -> e { emit :syntax_error, e ; false }  # false = yes more help
        )
        r or break
        r = argument_syntax.parse( argv, args,
          -> msg, * { emit :syntax_error, msg ; false }
        )
        r or break
        r = [ bound_invocation_method, args ]
      end while nil
      if false == r
        r = help
      end
      r
    end
  end


  module ActionKlassInstanceMethods
    include ActionInstanceMethods
    alias_method :builder, :_klass
  end


  module Action::ModuleMethods
    include MetaMethods
    def argument_syntax
      @argument_syntax ||= begin
        o = ArgumentSyntax.new(
          ->{ unbound_invocation_method.parameters },
          ->{ option_syntax.any? } )
        o
      end
    end

    def build parent
      o = new
      o.parent = parent
      o
    end

    attr_reader :desc ; alias_method :desc_ivar, :desc

    def desc *a
      redef = ->( *aa  ) do
        _desc = aa.flatten
        singleton_class.send :undef_method, :desc # so no warnings
        define_singleton_method :desc do |*aaa|
          if aaa.length.nonzero? or desc_ivar.nil?
            @desc = true
            instance_exec( *( _desc + aaa ), &redef )
          else
            _desc
          end
        end
        desc
      end
      instance_exec( *a, &redef )
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

    def unbound_invocation_method
      instance_method :invoke
    end
  end



  module NamespaceInstanceMethods
    include ActionInstanceMethods

    attr_accessor :anchor_module

    def fetch token, &not_found
      result = nil
      begin
        result = b = fetch_builder( token, &not_found )
        result or break
        o = b.respond_to?(:build) ? b.build(self) : b.new
        o2 = o.respond_to?(:resolve) ? o : RuntimeInferred.new(self, o, b)
        result = o2
      end while nil
      result
    end

                                  # in the spirit of .fetch
    def fetch_builder token, &not_found
      result = nil
      begin
        err = nil
        m = find token do |o|
          o.on_error do |e|
            err = e
          end
        end
        if err
          f = not_found || -> e { raise ::KeyError.new e.message }
          result = f[err]
          break
        end
        m or break # unlikely
        if ! m.respond_to?(:build) && ::Module === m && ! (::Class === m)
          result = NamespaceInferred.new m
        else
          result = m
        end
      end while nil
      result
    end


    on_find = PubSub::Emitter.new ambiguous: :error,
      not_found: :error, not_provided: :error


                                  # result is nil or builder
    define_method :find do |token, &error|
      result = nil # resolve the match early! (flyweighting ick)
      begin
        e = on_find.new error
        if ! token
          e.emit :not_provided, "expecting #{ syntax }"
          break
        end
        found = [] ; builder = nil ; rx = /^#{ ::Regexp.escape token }/
        actions.names.each do |act|
          a = act.aliases.grep rx
          first_match = a.reduce do |m, name|
            if name == token
              result = act.builder  # 1st whole match always wins the whole show
              break
            end
            m
          end
          result and break        # found an exact match, done
          if first_match
            found.push first_match
            builder = if act.respond_to? :builder then act.builder else act end
            builder or fail 'sanity - action.builder returned nil?'
          end
        end
        result and break          # and so on
        case found.length
        when 0 ; e.emit :not_found, "invalid action #{ token.inspect }. #{
                   }expecting #{ syntax }"
        when 1 ; result = builder # fuzzy match, found 1 match
        else   ; e.emit :ambiguous, "ambiguous action #{ token.inspect }. #{
                   }did you mean #{ or_ found.map { |n| "#{ pre n }" } }?"
        end
      end while nil
      result
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
      result = nil
      begin
        token = argv.shift
        o = fetch token do |e|
          result = help message: e.message, syntax: false
          nil # the fetch must still fail regardless of what help returns!
        end
        o or break
        result = o.resolve argv
      end while nil
      result
    end

    def syntax
      "{#{ actions.names.visible.map { |a| pre a.aliases.first } * '|' }}"
    end
  end


  module NamespaceModuleMethods
    include Action::ModuleMethods
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

    def init *a
      -> y do
        a.each do |e|
          e.each do |o|
            y << o
          end
        end
      end
    end

    alias_method :helps, :_self # hook for stubbing

    alias_method :names, :_self # hook for stubbing
  end


  class Constants < ActionEnumerator

    def init mod
      mod or fail 'sanity - where is mod'
      flyweight = nil
      -> y do
        mod.constants.each do |const|
          m = mod.const_get const, false
          o = if m.respond_to? :action_meta
            m.action_meta
          else
            flyweight ||= MetaInferred.new
            flyweight.set! m
          end
          y << o
        end
      end
    end
  end


  class ArgumentSyntax < ::Struct.new :params, :takes_options
    extend MetaHell::Let # we freeze and memoize

    parameter_string = -> o do
      pre, post = case o.type
      when :req  ;
      when :opt  ; ['[', ']']
      when :rest ; ['[', '[..]]']
      else       ; fail "sanity - unhandled param type - #{ o.type }"
      end
      "#{ pre }<#{ o.name }>#{ post }"
    end

    struct = ::Struct.new :type, :name

    define_method :[] do |idx|
      o = parameters.fetch( idx ) { struct[ :req, "arg#{ idx + 1 }" ] }
      parameter_string[ o ]
    end

                                  # atomicly prepend all or none of the elements
                                  # from argv to args, mutating both, iff argv's
                                  # length is syntacticly valid pursuant to the
                                  # syntax. result is true on parsing success,
                                  # else the result of a call to the appropriate
                                  # callback, which gets passed two arguments:
                                  # a message string and the relevant metadata.

    def parse argv, args, missing, unexpected=missing
      counts = parameters.reduce( ::Hash.new { |h, k| h[k] = 0 } ) do |m, p|
        m[p.type] += 1            # what are the counts of each type of
        m                         # parameter (:req, :opt, :rest) ?
      end
      min_arity = counts[:req]    # the min you can have is the # of req args
      max_arity = counts.values.reduce(:+) if counts[:rest].zero? # idem
      r = nil
      begin
        if argv.length < min_arity
          o = parameters.select{ |p| :req == p.type }[ argv.length ]
          r = missing[ "missing argument: #{ o.name }", o.name ]
          break
        end
        if max_arity and argv.length > max_arity
          val = argv[max_arity]
          r = unexpected[ "unexpected argument: #{ val }", val ]
          break
        end
        args[0, 0] = argv # splice its contents into the beginning and
        argv.clear        # make it empty
        r = true
      end while nil
      r
    end

    define_method :string do
      parameters.map { |o| parameter_string[ o ] }.join ' '
    end

  protected

    def initialize *a
      @__memoized = { } # ick, before the freeze
      super
      freeze
    end

    alias_method :dupe, :dup # careful!

    let :parameters do # maybe public one day
      a = params.call
      takes_options.call and a.pop
      b = a.map { |o| struct[ * o ] }
      b
    end
  end


  class OptionSyntax < ::Struct.new :definitions, :documentor_class,
    :parser_class, :do_help

    include Styles
    def self.build
      new [], ::OptionParser, ::OptionParser
    end

    def any?
      definitions.any?
    end

    def build
      self.class.new definitions.dup, documentor_class, parser_class, do_help
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

    def help y # !
      documentor.summarize do |line| # use optparse interface!
        y[ line ]
      end
      nil
    end

    def help!
      self[:do_help] = true
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

    def parse argv, args, help, syntax_error # result is true or result
      r = nil                     # of one of the callbacks `help`, or `se`
      begin
        if definitions.empty?
          if ! do_help
            r = true              # parsing with the empty option syntax
            break                 # (and no help) is a no-op, always success.
          end                     # (and note it leaves and '-h' in argv!)
        else
          opts_h = { }            # your one and only options hash for this
          args.push opts_h        # request. note we make it (and append to
        end                       # args) IFF there is one or more defn blocks.
        o = parser_class.new
        o.on '-h', '--help' do    # with or w/o defn blocks we might do this
          r = help.call           # (simply call the callback, caller decides
        end                       # how to handle this.)
        definitions.each do |f|
          o.instance_exec opts_h, &f # run each definition block passing
        end                       # the same opts hash into its scope.

        r = true                  # do this before below so above help.call
                                  # can change the value (typically it is set
        begin                     # set to nil to indicate no more processing)
          o.parse! argv           # mutate argv, opts_h gets results (e.g.)
        rescue ::OptionParser::ParseError => e
          r = syntax_error[ e ]   # let caller decide both
                                  # how to handle this and what the result
        end                       # should be.
      end while nil
      r                           # note that this should always be true
    end                           # or the result of a er[] call


    # the below is jawbreak blood . this will all go away soon like a bad dream
    def string
      result = nil
      if ! definitions.empty?
        x = documentor.instance_variable_get('@stack')[2].instance_variable_get('@list') # less hacky is out of scope
        a = x.map do |s|
          if s.respond_to? :short
            "[#{ s.short.first or s.long.first }#{ s.arg }]"
          end
        end
        a.compact!
        if ! a.empty?
          result = a.join ' '
        end
      end
      result
    end
  end


  class Runtime
    extend Action
    include NamespaceInstanceMethods
    def actions
      Actions[ Constants[anchor_module], Officious.actions ]
    end

    def anchor_module
      self.class::Actions
    end

    def invoke argv
      block_given? and raise ::ArgumentError.new 'no blocks to `invoke` ever'
      result = nil
      callable, args = resolve argv.dup
      if callable
        result = callable.receiver.send callable.name, *args
      else
        result = callable
      end
      result
    end

    def program_name
      @program_name || ::File.basename( $PROGRAM_NAME )
    end

    attr_writer :program_name

  protected

    def initialize *a
      @program_name = nil
      super
    end
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
      parent.respond_to? :emit or fail "sanity - is parent not an emitter?"
      self.parent = parent
      set! reflector
    end

    def syntax # tricky: we are using this class IFF we don't have options
      ArgumentSyntax.new(
        -> { @reflector.unbound_invocation_method.parameters },
        -> { false }
      ).string
    end
  end


  class RuntimeInferred < DocumentorInferred
    def initialize parent, built, builder
      super(parent, builder)
      @bound_invocation_method = built.method :invoke
    end
    attr_reader :bound_invocation_method
  end


  class NamespaceInferred
    include NamespaceInstanceMethods

    def actions
      anchor_module or fail "sanity - where is anchor_module - #{
        }call _namespace_inferred_init! on construction"
      c = Constants[anchor_module]
      o = Officious.actions
      x = Actions[c, o]
      x
    end

    def build parent
      self.parent = parent
      self
    end

    def initialize module_with_actions
      _namespace_inferred_init! module_with_actions
    end

    alias_method :reflector, :anchor_module # for documentation generation

    alias_method :builder, :anchor_module   # for find

    def _namespace_inferred_init! module_with_actions
      module_with_actions or fail 'sanity - huh?'
      self.anchor_module = module_with_actions
    end
  end


  module Officious
    def self.actions
      Constants[self]
    end
  end


  class Officious::Help
    extend Action
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
      self.parent = rt   # assuming singleton, be careful
      self
    end

    def invoke token=nil # #todo this signature violates #convention [#hl-020]
      result = nil
      begin
        if token
          b = parent.fetch_builder token do |e|
            emit :error, e.message
            result = false
            nil # set b!
          end
          b or break
          o = if b.respond_to? :build
            b.build parent
          else
            b.new
          end
          d = if o.respond_to? :help
            o
          else
            DocumentorInferred.new parent, b
          end
          d.help full: true # `o` gets thrown away sometimes
        else
          parent.help full: true
        end
      end while nil
      result
#     which do you prefer, above or below? #eye-blood
#     token or return @parent.help(full: true)
#     o = (b = @parent.fetch_builder(token) { |e| return emit(:error, e.message) }).respond_to?(:build) ? b.build(@parent) : b.new
#     (o.respond_to?(:help) ? o : DocumentorInferred.new(@parent, b)).help(full: true) # 'o' gets thrown away sometimes
    end

    def visible?
      false
    end
  end
end
