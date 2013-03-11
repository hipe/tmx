module Skylab::Treemap
  class CLI::Action
    # 1) this has been almost totally divorced from the legac f.w except for
    # these kind of proxy nerks below.
    # 2) we are allowing for the possibility that other parts of the system
    # will want to leverage action-like methods without necessarily subclassing
    # (hence the open-and-close-and-open dance below)
  end

  module CLI::Action::InstanceMethods  # might be borrowd by motes, cards, flies
    include Headless::CLI::Action::InstanceMethods
    include Treemap::Core::Action::InstanceMethods # might override some legacy

    def help *a                  # [#012]
      if 1 == a.length && { full: true }
        a.pop  # then legacy came in thru the front `tm -h act'
      end
      super
    end

    def summary_lines            # public for legacy - not universal
      y = [ ]
      _summary_lines y
      if @adapters
        summary_lines_for_adapters y
      end
      y
    end

  protected
                                  # (there are some things we need if we didn't
                                  # go thru `invoke`..)
    def __legacy_init_ui
      option_parser
      @queue ||= [ ]
      nil
    end

    def build_option_parser       # rudimentary impl. that reads these defs,
      a = self.class.option_parser_blocks  # if you're not using ridiculous
      if a.length.nonzero?        # and etc. (e.g. adapter actions)
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
    extend Headless::CLI::Action::ModuleMethods
    include Treemap::CLI::Action::InstanceMethods

    MODALITIES_ANCHOR_MODULE = Treemap

    ACTIONS_ANCHOR_MODULE = -> { Treemap::CLI::Actions }

    #         ~ public methods called by the legacy f.w ~


    def options                   # used by stylus ick to impl. `param`
      option_syntax.options
    end

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
        $stderr.puts "OK NEAT:-->#{ x }<--"  # #todo
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
      invoke args  # yes, you could just etc - but this is a debugger entrypoint
                   # takes us into our sanctuary - clean h.l parsing
    end

    #         ~ for when adapter actions get passed to the f.w ~

    def legacy_proxy
      @legacy_proxy ||= __build_legacy_proxy
    end

    # --*--

  protected

    def initialize rc=nil         # porcelain gives you nothing, but adapters
      @parent = nil               # in Action_Flyweight_ we make emissaries
      super( rc )                 # sets @parent via request_client=
    end

    def api_action                # experimentally the cli action builds the
      @api_action ||= begin       # api action, the tree grows downward
        kls = self.class.modalities_anchor_module::API::Actions.const_fetch(
          normalized_action_name ) # (was [#034])
        action = kls.new self
        wire_api_action action
        action
      end
    end

    def default_action            # compat h.l
      :process                    # (`invoke` belongs to the framework
    end                           #  `execute` is for when we take no args)

    def request_client            # away at [#012]
      @parent
    end

    def request_client= x         # away at [#012]
      @parent and fail "sanity"
      @parent = x
    end

    def wire_api_action api_action
      request_client.send :wire_api_action, api_action
      stylus = request_client.send :stylus     # [#011] unacceptable
      api_action.stylus = stylus
      stylus.set_last_actions api_action, self # **TOTALLY** unacceptable
      nil
    end

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
