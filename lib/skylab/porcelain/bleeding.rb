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

    def is_visible
      true
    end

    def _klass
      self.class
    end

    alias_method :reflector, :_klass

    def summary_lines
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
      if parent
        parent.send :emit, *a
      else
        fail "sanity - where is parent of this #{ self.class }?"
      end
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
      @option_syntax ||= build_option_syntax
    end

    def option_syntax_class
      OptionSyntax
    end

    attr_accessor :parent

    def parameters ; argument_syntax.parameters end # @delegates_to

    def program_name
      "#{ parent.program_name } #{ aliases.first }"
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

  protected

    def build_option_syntax
      self.class.option_syntax.dupe
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

    def option_syntax &block
      @option_syntax ||= begin
        osy = option_syntax_class.new
        # option_syntax_class osy # hack to get this to descend, will go away
        osy
      end
      if block
        @option_syntax.define!(& block )
        nil
      else
        @option_syntax
      end
    end

    def option_syntax_class klass=nil
      if klass.nil?
        OptionSyntax
      else
        redef = -> k2 do
          undef_method :option_syntax_class
          define_method :option_syntax_class do k2 end
          class << self
            undef_method :option_syntax_class
          end
          define_singleton_method :option_syntax_class do |k3=nil|
            if k3.nil?
              k2
            else
              instance_exec k3, &redef
            end
          end
        end
        instance_exec klass, &redef
      end
    end

    def _self;   self        end

    alias_method :reflector, :_self

    def summary &block
      raise ::ArgumentError.new 'dsl writer only. requires block' if ! block
      summary_lines(& block )
    end

                                  # #todo - not ok - this was fun when we
                                  # were young and dumb but now this eye-blood
                                  # is not worth the cleverness. the point has
                                  # been made and a rewrite is in order
    def summary_lines &block
      redef = -> b3 do
        define_singleton_method :summary_lines do |&b4|
          if b4
            instance_exec b4, &redef
          else
            instance_exec(& b3)
          end
        end
      end
      instance_exec( ( block || -> { (desc || [])[ 0..1 ] } ), &redef )
      if ! block
        summary_lines
      end
    end

    def unbound_invocation_method
      instance_method :invoke
    end
  end

  module NamespaceInstanceMethods
    include ActionInstanceMethods

    attr_accessor :action_anchor_module

    def fetch token, &not_found
      res = fetch_builder token, &not_found
      if res
        kls = res
        act = if kls.respond_to? :build
          kls.build self
        else
          kls.new
        end
        res = if act.respond_to? :resolve then act
        else
          RuntimeInferred.new self, act, kls
        end
      end
      res
    end
                                  # in the spirit of .fetch
    def fetch_builder token, &not_found
      es = nil
      mod = find token do |o|
        o.on_error do |er|
          res = ( not_found || -> e { raise ::KeyError, e.message } ) [ er ]
        end
      end
      if mod
        if mod.respond_to?(:build) || !(::Module === mod && ! (::Class === mod))
          res = mod
        else
          res = NamespaceInferred.new mod
        end
      end
      res
    end

    resolve_builder = -> act do
      bld = if act.respond_to? :builder then act.builder else act end
      bld or fail 'sanity - action.builder returned nil?'
      bld
    end

    on_find = PubSub::Emitter.new ambiguous: :error,
      not_found: :error, not_provided: :error

                                  # result is nil or builder
                                  # 1st exact match steals the whole show
    define_method :find do |token, &error|
      res = nil
      begin
        e = on_find.new error
        if ! token
          e.emit :not_provided, "expecting #{ syntax }"
          break( res = false )
        end
        builder = nil ; found = [] ; rx = /^#{ ::Regexp.escape token }/
        actions.names.each do |act|
          fnd = act.aliases.grep rx
          if fnd.length.nonzero?
            if fnd.include? token
              break( res = resolve_builder[ act ] ) # (note we set res)
            end
            found.push fnd.first
            builder = resolve_builder[ act ]
          end
        end
        res and break             # and so on
        case found.length
        when 0 ; e.emit :not_found, "invalid action #{ token.inspect }. #{
                   }expecting #{ syntax }"
        when 1 ; res = builder # fuzzy match, found 1 match
        else   ; e.emit :ambiguous, "ambiguous action #{ token.inspect }. #{
                   }did you mean #{ or_ found.map { |n| "#{ pre n }" } }?"
        end
      end while nil
      res
    end

    def help_invite o=nil
      a, b = if (o && o[:full]) then ['<action>',   " on a particular action."]
                                else ['[<action>]'] end
      emit :help, "try #{pre "#{program_name} #{a} -h"} for help#{b}"
    end

    def help_list
      tbl = actions.helps.visible.reduce [] do |rows, help|
        rows << [ help.aliases.first, ( help.summary_lines || [] ) ]
        rows
      end
      emit :help, (tbl.length.zero? ? "(no actions)" : "#{hdr 'actions:'}")
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

    attr_reader :last_fetch_result

    def resolve argv # mutates argv .. here is the secret to our tail call rec.
      res = nil
      x = fetch argv.shift do |e|
        res = help message: e.message, syntax: false
        nil                       # *ensure* that x is false-ish!
      end
      if x
        res = x.resolve argv
      end
      res
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
        b or raise ::ArgumentError.new "block must be given if args are not"
      end
      super(&@block)
    end

    def filter &b
      self.class.new { |y| each { |*a| b.call(y, *a) } }
    end

    def _self   ; self                                                   end
    def visible ; filter { |y, a| y << a if a.is_visible }               end
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

                                  # *no* exclamation! [#po-016]
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
      args = params.call
      args.pop if takes_options[]
      res = args.map { |o| struct[ * o ] }
      res
    end
  end

  class OptionSyntax
    include Styles

    def any?
      @definitions.length.nonzero?
    end

    def define! &block
      @definitions.push block
      @on_definition_added_h.each do |_, b|
        instance_exec( &b )
      end
      nil
    end

    def dupe
      otr = self.class.new @definitions.dup, @documentor_class, @parser_class,
        @do_help
      otr
    end

    attr_accessor :definitions

    attr_accessor :do_help

    def documentor
      @documentor ||= begin
        d = @documentor_class.new
        documentor_visit d
        d
      end
    end

    attr_accessor :documentor_class

    def help y # !
      documentor.summarize do |line| # use optparse interface! - keep [#po-015]
        y[ line ]
      end
      nil
    end

    def help!
      @do_help = true
      nil
    end

    attr_reader :on_definition_added_h

                                  # *no* exclamation! [#016]
    def parse argv, args, help, syntax_error # result is true or result
      r = nil                     # of one of the callbacks `help`, or `se`
      begin
        if definitions.length.zero?
          if ! do_help
            break( r = true )     # parsing with the empty option syntax
          end                     # (and no help) is a no-op, always success.
        else                      # (and note it leaves and '-h' in argv!)
          opts_h = { }            # your one and only options hash for this
          args.push opts_h        # request. note we make it (and append to
        end                       # args) IFF there is one or more defn blocks.
        o = parser_class.new
        o.on '-h', '--help' do    # with or w/o defn blocks we might do this
          r = help[]              # (simply call the callback, callee decides
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

    attr_accessor :parser_class

    def string
      res = nil
      if definitions.length.nonzero?
        string_a = switches.reduce [] do |m, sw|
          if sw.respond_to? :short
            m << "[#{ sw.short.first || sw.long.first }#{ sw.arg }]"
          end
          m
        end
        if string_a.length.nonzero?
          res = string_a.join ' '
        end
      end
      res
    end

  protected

    def initialize definitions=[], documentor_class=::OptionParser,
      parser_class=::OptionParser, do_help=nil
      @definitions, @documentor_class, @parser_class, @do_help =
        definitions, documentor_class, parser_class, do_help
      @documentor = nil
      @switches = nil
      @on_definition_added_h = { }
    end

    def documentor_visit doc
      @on_definition_added_h[:documentor] ||= -> do
        fail 'sanity - you probably want this hook to be set for documentors'
      end
      doc.banner = "#{ hdr 'options:' }"
      null_h = { }
      @definitions.each { |b| doc.instance_exec null_h, &b }
      nil
    end

    def switches
      @switches || documentor.top.list # we don't memoize it but you might
    end
  end

  class Runtime
    extend Action
    include NamespaceInstanceMethods

    def actions
      Actions[ Constants[action_anchor_module], Officious.actions ]
    end

    def action_anchor_module
      self.class::Actions
    end

    def invoke argv
      block_given? and raise 'no blocks here ever'
      res = nil
      method, args = resolve argv.dup
      if method
        res = method.receiver.send method.name, *args
      else
        res = method
      end
      res
    end

    attr_reader :program_name

    alias_method :program_name_ivar, :program_name

    def program_name
      program_name_ivar || ::File.basename( $PROGRAM_NAME )
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
    def initialize parent, reflector, _obj=nil
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
      action_anchor_module or fail "sanity - where is action_anchor_module - #{
        }call _namespace_inferred_init on construction"
      c = Constants[action_anchor_module]
      o = Officious.actions
      x = Actions[c, o]
      x
    end

    def build parent
      self.parent = parent
      self
    end

    def initialize module_with_actions
      _namespace_inferred_init module_with_actions
    end

    alias_method :reflector, :action_anchor_module # for documentors

    alias_method :builder, :action_anchor_module   # for find

    def _namespace_inferred_init module_with_actions
      module_with_actions or fail 'sanity - huh?'
      self.action_anchor_module = module_with_actions
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
            DocumentorInferred.new parent, b, o
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

    def is_visible
      false
    end
  end
end
