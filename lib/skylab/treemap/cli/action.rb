module Skylab::Treemap

  class CLI::Action
    # 1) this has been almost totally divorced from the legac f.w except for
    # these kind of proxy nerks below.
    # 2) we are allowing for the possibility that other parts of the system
    # will want to leverage action-like methods without necessarily subclassing
    # (hence the open-and-close-and-open dance below)
  end

  CLI::Action::FUN = -> do

    o = ::Struct.new( :build_event ).new

    # it was too hard and too ridiculous to try to wedge this into the
    # mode client and the actions without overwriting a bunch of stuff.
    o[:build_event] = -> stream_name, text do
      @event_factory[ self.class, stream_name, text ]
    end

    o
  end.call

  module CLI::Action::InstanceMethods  # might be borrowd by motes, cards, flies

    include Headless::CLI::Action::InstanceMethods  # the current favorite for
                                  # cli basics like `invoke`

    include Treemap::Core::Action::InstanceMethods # brings in our own custom
                                  # subclient methods among other things

    def help *a                   # [#012]
      if 1 == a.length && { full: true }
        __legacy_init_ui
        a.pop  # then legacy came in thru the front `tm -h act'
      end
      super
    end

    def summary_lines             # public for legacy - not universal
      y = [ ]
      _summary_lines y
      if @adapters
        summary_lines_for_adapters y
      end
      y
    end

  private

    #         ~ custom event building ~

    define_method :build_event, & CLI::Action::FUN.build_event

                                  # (there are some things we need if we didn't
                                  # go thru `invoke`..)
    def __legacy_init_ui
      option_parser
      @queue ||= [ ]
      nil
    end

    def build_option_parser       # rudimentary impl. that reads these defs,
      a = self.class.option_parser_blocks  # if you're not using ridiculous
      if a && a.length.nonzero?   # and etc. (e.g. adapter actions)
        @param_h ||= { }          # a common choice
        op = ::OptionParser.new
        a.each { |b| instance_exec op, &b }
        op
      end
    end

    def slug                      # [#054]
      @name.as_slug
    end

    def summary_lines_for_adapters y
      a = @adapters.reduce [] do |yy, adapter|
        yy << adapter.name.as_slug
      end
      x = and_ a.map(& method(:val))
      if @is_native
        y << "(can utilize plugin#{ s a } #{ x })"
      else
        y << "#{ val name.as_slug } for the #{ x } plugin#{ s a }"
      end
      y
    end
  end

  class CLI::Action
    #         ~ because we are a class of action: ~

    extend Headless::CLI::Action::ModuleMethods    # basic CLI DSL methods lik
                                        # `option_parser` and `desc` (writers)
    MODALITIES_ANCHOR_MODULE = Treemap  # actions can reach classes from
                                        # the rest of the system
    ACTIONS_ANCHOR_MODULE = -> { Treemap::CLI::Actions }  # actions can
                                        # infer their full normalized
                                        # name from their class name

    #         ~ for our event profile: ~

    include Headless::CLI::Action::InstanceMethods  # NOTE *that* ver. of `emit`

    extend PubSub::Emitter        # (child classes *must* declare their own
                                  # event profile, also defaults are assumed
                                  # in `initialize` here!)  NOTE this ver.

    include Treemap::CLI::Action::InstanceMethods  # our own custom generic cli
                                  # NOTE *this* version of `build_event`

    event_factory CLI::Event::FACTORY
                                  # a reasonable default for today

    #         ~ for noun inflection when reporting actions ~

    extend Headless::NLP::EN::API_Action_Inflection_Hack
    inflection.lexemes.noun = 'treemap'  # (these classes here are verbs)

    public :usage_and_invite  # for [#035] annotated invites

    #         ~ reflection and fun ~

    def fetch_actual_parameter norm, &b  # assumes post-execute
      actual_parameters_box.fetch norm, &b
    end

    def actual_parameters_box
      if @actual_parameters_box.nil?
        @actual_parameters_box = if @param_h_spent
          MetaHell::Formal::Box.around_hash @param_h_spent  # frozen h, btw
        else
          false
        end
      end
      @actual_parameters_box
    end ; private :actual_parameters_box


    #         ~ public methods called by the legacy f.w ~

    #      ~ (watch how we bend a huge new api to a huge old one:) ~

    module Proxy
    end

    Proxy::Option_Syntax = MetaHell::Proxy::Functional.new(
      :any?, :help, :options, :parse, :string )

                                  # mock a legcay o.syn with a hookback so
    def option_syntax             # we can get control back to here, a hack!
      @option_syntax ||= Proxy::Option_Syntax.new(
        :options => method( :__option_syntax_options ),
        :parse => method( :__option_syntax_parse_legacy ),
        :string => method( :__option_syntax_string_legacy ),
        :any? => method( :__option_syntax_any_legacy ),
        :help => method( :__option_syntax_help_legacy )
      )
    end

    def __option_syntax_any_legacy
      # err on the side of futurism and assume we could have an option_parser
      # but have a zero length set of definitions for it
      !! option_parser_blocks  # relies upon the sweetening from [#tr-009]
    end

    def __option_syntax_help_legacy f
      # the legacy nerk invoke straight up help..
      y = ::Enumerator::Yielder.new do |x|
        Stderr_[].puts "OK NEAT:-->#{ x }<--"  # #todo
      end
      help_options y
      nil
    end

    def __option_syntax_parse_legacy argv, *_ # headless does not think it is
      # appropriate to take action while in the middle of parsing arguments.
      # however nerky nerky derky dery
      rs = parse_opts argv        # rides you into headless
      true == rs ? true : nil     # we've got to swallow the false i guess..
    end

    def __option_syntax_options
      option_documenter.options
    end

    def __option_syntax_string_legacy # i hope your eyes like having blood in
      # them: for lvl 0 errs (missing arg), legacy catches that and needs this.
      # but for a lvl1 err (bad opt), headless will do the equivalent of this
      render_option_syntax  # oh i guess that wasn't that bad actually
    end

    def resolve args  # #legacy wiring:
      [ method( :__legacy_invoke ), [ args ] ]
    end
    # =
    def __legacy_invoke args
      invoke args  # yes, you could just etc - but this is a d-ebugger entrypoint
                   # takes us into our sanctuary - clean h.l parsing
    end

    #         ~ for when adapter actions get passed to the f.w ~

    def legacy_proxy
      @legacy_proxy ||= __build_legacy_proxy
    end

    # --*--

  private


    def initialize mc
      Treemap::CLI::Client === mc or fail "test me - modal client? #{ mc.class }"
      init_treemap_sub_client -> { mc }
      on_info      mc.handle :info
      on_info_line mc.handle :info_line
      on_error     mc.handle :error
      on_help      mc.handle :info_line
      if_unhandled_streams :raise
      @actual_parameters_box = nil
      nil
    end

    #         ~ api action building (in approximate order) ~

                                  # experimentally the cli action builds the
    def api_action                # api action, the tree grows downward
      @api_action ||= build_wired_api_action
    end

    alias_method :sister, :api_action  # experimental conventional name etc

    def build_unwired_api_action
      kls = self.class.modalities_anchor_module::API::Actions.const_fetch(
        normalized_action_name ) # (was [#034])
      kls.new self
    end

    #         ~ rendering of particular api etc things ~

    # This is our version of [#hl-036] (fixes [#011]): the modal action
    # decides how to render parameters as they get mentioned for
    # rendering to the target mode.

    def param x, render_method=nil             # generic rendering of params
      ::Symbol === x or x = x.local_normal_name
      opt = option_parser.options.fetch x do end
      if opt
        str = opt.send( render_method || :render )
      else
        attr = sister.formal_attributes.fetch x do end
        if attr
          str = attr.label_string
        else
          str = x.to_s
        end
      end
      pre str
    end

    #         ~ compat h.l ~

    def default_action            # compat h.l
      :process                    # (`invoke` belongs to the framework
    end                           #  `execute` is for when we take no args)

    #         ~ for when f.w is touching an adapter action raw ~

    class LegPxy < MetaHell::Proxy::Nice.new :help, :resolve
      def respond_to?(*) true end  # i want it all
    end

    def __build_legacy_proxy
      LegPxy.new(
        help:                method( :__legacy_help ),
        resolve:             method( :__legacy_resolve )
      )
    end

    def __legacy_help h
      if { full: true } == h
        __legacy_init_ui
        help
      else
        fail 'implement me'  # #todo
      end
    end

    def __legacy_resolve argv
      [ method( :invoke ), [ argv ] ]
    end
  end
end
