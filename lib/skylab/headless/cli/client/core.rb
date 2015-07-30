module Skylab::Headless

  module CLI::Client  # read [#089] the CLI client narrative #storypoint-5

    class << self

      def [] mod, * x_a

        edit_module_via_mutable_iambic mod, x_a
      end

      def call_via_arglist x_a

        edit_module_via_mutable_iambic x_a.shift, x_a
      end

      def edit_module_via_mutable_iambic mod, x_a

        if x_a.length.zero?
          x_a.concat DEFAULT_BUNDLES_X_A__
        end

        Bundles_.edit_module_via_mutable_iambic mod, x_a
      end
    end

    DEFAULT_BUNDLES_X_A__ = %i( client_instance_methods )

    module Bundles_

      Actions_anchor_module = -> x_a do
        module_exec x_a, &
          Home_::Action::Bundles::Actions_anchor_module.to_proc
      end

      Client_instance_methods = -> _ do
        include IMs__ ; nil
      end

      Client_services = -> x_a do
        module_exec x_a, & Home_::Client::Bundles::Client_services.to_proc
      end

      DSL = -> _ do
        if ! private_method_defined? :build_pen
          module_exec nil, & Client_instance_methods
        end
        module_exec _, & DSL__.to_proc
      end

      Three_streams_notify = -> _ do
        include IMs__
        module_exec( & Three_streams_notify_methods__ ) ; nil
      end

      Home_.lib_.bundle::Multiset[ self ]
    end

      Three_streams_notify_methods__ = -> do
      private

        def errstream  # let this be the only one in the universe
          @IO_adapter.errstream
        end

        def three_streams
          @IO_adapter.to_three
        end

        def three_streams_notify i, o, e
          instance_variable_defined? :@IO_adapter and raise "write once"
          @IO_adapter = build_IO_adapter i, o, e, build_pen ; nil
        end
      end

    module IMs__

      include Home_::Client::InstanceMethods, CLI::Action_::IMs

      def initialize *a
        @program_name = nil
        instance_exec a, & INITIALIZE_P_H__.fetch( a.length )
        super()  # (headless inits tombstone [#052] #todo:during-merge)
      end

      attr_writer :program_name  # public for ouroboros [#054]

      CLI::Client::INITIALIZE_P_H__ = {
        0 => MONADIC_EMPTINESS_,
        3 => -> a do
          @IO_adapter = build_IO_adapter( * a )
        end }.freeze

    private

      def build_IO_adapter i=dflt_sin, o=dflt_sout, e=dflt_serr, pen=build_pen
        # #storypoint-255 what is really nice is if you observe [#sl-114] a..
        _IO_adapter_class.new i, o, e, pen
      end

      def dflt_sin ; Home_::CLI::IO.instream end
      def dflt_sout ; Home_::CLI::IO.outstream end
      def dflt_serr ; Home_::CLI::IO.errstream end

      def pen_class  # #hook-out
        CLI.pen.minimal_class
      end

      def _IO_adapter_class
        Home_::CLI::IO::Adapter::Minimal
      end

      # ~ :#hook-in's #topper-stopper's #buck-stop whatever

      def normalized_invocation_string_prts y
        y << normalized_invocation_string ; nil
      end ; public :normalized_invocation_string_prts # #todo:during-merge

      def normalized_invocation_string
        program_name
      end

      def program_name
        @program_name or ::File.basename $PROGRAM_NAME
      end

      # ~ #storypoint-205, these methods

    public  # #todo:during-merge

      def emit_info_line_p
        emit_help_line_p
      end

      def emit_help_line_p
        @emit_help_line_p ||= method :emit_help_line
      end

      def emit_payload_line_p
        @emit_payload_line_p ||= method :emit_payload_line
      end

    protected

      def emit_help_line s  # #todo:during-merge, this was just to re-green tests
        call_digraph_listeners :help, s ; nil
      end

      def emit_error_line s
        emit_info_line s
      end

      def emit_info_line s
        @IO_adapter.errstream.puts s ; nil
      end

      def emit_payload_line s
        @IO_adapter.outstream.puts s ; nil
      end

      # ~ #storypoint-305 agent-like facety-things

      def common_resolve_IO_adapter_instream  # #storypoint-310  # :+#hook-in courtesy method
        _stx = argument_syntax_for_action_i default_action_i
        Client_::Actors__::Resolve_instream[ @argv, @IO_adapter, _stx, self ]
      end

      # ~ things that will turn into services  # #todo:during-merge

      def parameter_label x, idx=nil  # [#036] explains it all, somewhat
        idx = "[#{ idx }]" if idx
        if ::Symbol === x
          stem = Callback_::Name.via_variegated_symbol( x ).as_slug
        else
          stem = x.name.as_slug  # errors please
        end
        em "<#{ stem }#{ idx }>"
      end

      def info msg  # barebones implementation as a convenience for this
        # shorthand commonly used in debugging and verbose modes
        call_digraph_listeners :info, msg ; nil  # #todo:after-mergge
      end
    end

    module DSL__ # read [#129] (in [#089]) the CLI client D.. #storypoint-905

      to_proc = -> _ do  # #storypoint-910 the order here matters
        CLI::Box[ self, :DSL ]  # NOTE method_added hook
        include IMs__ ; nil
      end ; define_singleton_method :to_proc do to_proc end

      # #storypoint-920 (N/A) "we may implement bundles as procs below.."

      module IMs__
      private
        def build_option_parser  # #storypoint-925
          op = Home_::Library_::OptionParser.new
          p_a = self.class.any_option_parser_p_a
          p_a and apply_p_a_on_op p_a, op
          _yes = op_looks_like_it_defines_its_own_help op
          _yes or add_hlp_to_op op
          op
        end
        def op_looks_like_it_defines_its_own_help op
          match_p = say_with_lxcn( :SHRT_HLP_SW ).method :==
          op.top.list.detect do |sw|
            sw.respond_to? :short and match_p[ sw.short.first ]
          end
        end
        def add_hlp_to_op op
          _a = lexical_vals_at :SHRT_HLP_SW, :LNG_HLP_SW, :THS_SCRN
          op.on( * _a ) do
            enqueue :help
          end
          op
        end
      end
    end

    module Adapter  # #stowaway for [#054] ouroboros
      Autoloader_[ self ]
    end

    module Bundles__  # #stowaway
      Autoloader_[ self ]
    end

    CEASE_X_ = CLI::Action_::CEASE_X_

    Client_ = self

    module IMs__
      Adapter = Adapter  # covered
    end

    PROCEDE_X_ = CLI::Action_::PROCEDE_X_
  end
end
