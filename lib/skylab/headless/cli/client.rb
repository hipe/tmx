module Skylab::Headless

  module CLI::Client  # read [#132] the CLI client narrative #storypoint-10

    def self.[] mod, * x_a
      was_empty = x_a.length.zero?
      x_a.unshift :location_of_residence, caller_locations( 1, 1 ).first
      if was_empty
        x_a.concat DEFAULT_BUNDLES_X_A__
      end
      Bundles_.apply_iambic_on_client x_a, mod
    end

    DEFAULT_BUNDLES_X_A__ = %i( instance_methods )

    module Bundles_

      Actions_anchor_module = -> x_a do
        # module_exec x_a, & Headless::Action::Actions_anchor_module.to_proc  # #todo:during-merge
        extend Headless::Action::ModuleMethods
        x = x_a.shift
        _p = if x.respond_to? :call then x
             elsif x.respond_to? :id2name then
               -> { const_get x }
             else
               -> { x }
             end
        const_set :ACTIONS_ANCHOR_MODULE, _p ; nil
      end

      Client_services = -> x_a do
        module_exec x_a, & Headless::Client::Bundles::Client_services.to_proc
      end

      DSL = -> _ do
        module_exec _, & DSL__.to_proc
      end

      Instance_methods = -> _ do
        include IMs__ ; nil
      end

      Location_of_residence = -> x_a do
        @location_of_residence = x_a.shift ; nil  # clobber ok
      end

      Three_streams_notify = -> _ do
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

      MetaHell::Bundle::Multiset[ self ]
    end

    module IMs__

      include Headless::Client::InstanceMethods, CLI::Action::InstanceMethods

      def initialize *a
        @program_name = nil
        instance_exec a, & INITIALIZE_OP_H__.fetch( a.length )
        super()  # (headless inits tombstone [#052] #todo:during-merge)
      end

      attr_writer :program_name  # public for ouroboros [#054]

      CLI::Client::INITIALIZE_OP_H__ = {
        0 => MetaHell::MONADIC_EMPTINESS_,
        3 => -> a do
          @IO_adapter = build_IO_adapter( * a )
        end }.freeze

    private

      def build_IO_adapter i=$stdin, o=$stdout, e=$stderr, pen=build_pen
        # #storypoint-940 what is really nice is if you observe [#sl-114] a..
        _IO_adapter_class.new i, o, e, pen
      end

      def pen_class  # #hook-out for the above method
        CLI::Pen::Minimal
      end

      def _IO_adapter_class
        Headless::CLI::IO::Adapter::Minimal
      end

      # #todo:during-merge (action i.m should use these exclusively)

      def emit_error_line s
        @IO_adapter.errstream.puts s ; nil
      end
      def emit_info_line s
        @IO_adapter.errstream.puts s ; nil
      end

      # ~ :#hook-out #todo:during-merge (action i.m will do this one day)

      def build_option_parser
      end

      # ~ :#hook-in's #topper-stopper's #buck-stop whatever

      def normalized_invocation_string
        program_name
      end

      def program_name
        @program_name or ::File.basename $PROGRAM_NAME
      end

      # ~ things that will turn into services  # #todo:during-merge

      def resolve_instream_status_tuple  # (the probable destination of [#022], in flux)
        CLI::Client::Bundles__::Resolve_upstream[ self ]
      end

      def parameter_label x, idx=nil  # [#036] explains it all, somewhat
        idx = "[#{ idx }]" if idx
        if ::Symbol === x
          stem = Headless::Name::FUN.slugulate[ x ]
        else
          stem = x.name.as_slug  # errors please
        end
        em "<#{ stem }#{ idx }>"
      end

      def info msg  # barebones implementation as a convenience for this
        # shorthand commonly used in debugging and verbose modes
        emit :info, msg ; nil
      end
    end

    module DSL__ # read [#129] (in [#132]) the CLI client D.. #storypoint-950
      to_proc = -> x_a do  # #storypoint-960 the order here matters
        module_exec( & Wire_autoloader__ )
        module_exec x_a, & CLI::Box::DSL.to_proc  # NOTE 'method_added' hook
        module_exec nil, & Bundles_::Instance_methods.to_proc
        singleton_class.module_exec( & MMs__ ) ; include IMs__ ; nil
      end ; define_singleton_method :to_proc do to_proc end

      Wire_autoloader__ = -> do
        loc = @location_of_residence ; @location_of_residence = nil
        MetaHell::MAARS[ self, loc ] ; nil
      end

      # #storypoint-970 "we may implement bundles as procs below.."

      MMs__ = -> do
      private
        def default_action foo  # #storypoint-980
          define_method :default_action_i do foo end ; nil
        end
      end

        module IMs__
        private
          def build_option_parser  # #storypoint-990
            op = Headless::Services::OptionParser.new
            p_a = self.class.any_option_parser_blocks
            p_a and apply_p_a_on_op p_a, op
            _yes = op_looks_like_it_defines_its_own_help op
            _yes or add_hlp_to_op op
            op
          end
          def op_looks_like_it_defines_its_own_help op
            match_p = fetch_lexical_value( :SHRT_HLP_SW ).method :==
            op.top.list.detect do |sw|
              sw.respond_to? :short and match_p[ sw.short.first ]
            end
          end
          def add_hlp_to_op op
            _a = lexical_values_at :SHRT_HLP_SW, :LNG_HLP_SW, :THS_SCRN
            op.on( * _a ) do
              enqueue :help
            end
            op
          end
        end
    end

    module Adapter  # for [#054] ouroboros
      MetaHell::MAARS::Upwards[ self ]
    end

    module IMs__
      Adapter = Adapter  # covered
    end

    # ~ some API-private consts as "services"

    CEASE_X_ = false ; PROCEDE_X_ = true
  end
end
