module Skylab::TMX::TestSupport

  module Operations

    def self.[] tcc
      Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods__
    end

    # ==

    module ModuleMethods___

      def call_by & define

        once = -> do
          once = nil
          @operations_DSL_value_struct = DSL_Values___.new
          instance_exec( & define )
          remove_instance_variable( :@operations_DSL_value_struct ).call_array
        end

        define_method :__realease_operations_call_array do
          instance_exec( & once )
        end
      end
    end

    # ==

    DSL_Values___ = ::Struct.new :call_array

    # ==

    module InstanceMethods__

      # -- DSL

      def ignore_common_post_operation_emissions_
        ignore_emissions_whose_terminal_channel_symbol_is :operator_resolved
      end

      def call * x_a
        @operations_DSL_value_struct.call_array = x_a
      end

      # -- expectations & hook-outs

      def expect_parse_error_emission_lines_
        lines_via_this_kind_of_failure_via_array GENERIC_PARSE_ERROR_CHANNEL___
      end

      def send_subject_call
        _x_a = __realease_operations_call_array
        call_via_array _x_a
        execute
      end

      def expression_agent
        _ = Zerk_lib_[]::API::ArgumentScannerExpressionAgent.instance
        _  # #todo
      end

      def subject_API
        Home_::API
      end
    end

    # === LEGACY ([br]) BELOW

    if false
    Reactions = -> tcc do
      Common_.test_support::Expect_Event[ tcc ]
      Building[ tcc ]
    end

    # <-

  module Building

    def self.[] tcc
      tcc.include self
    end

    def build_and_call_ * x_a

      block_given? and self._NOT_YET

      _o = front_
      @result = _o.call( * x_a, & event_log.handle_event_selectively )
      NIL_
    end

    def build_mock_unbound_ sym
      TS_::Mocks::Unbound.new sym
    end

    define_method :build_shanoozle_into_ do | mod |

      # into the argument module build what is needed to make it a minimal
      # reactive model host, complete with one action and a running kernel

      bz = Home_.lib_.brazen

      mod::Models_ = ::Module.new  # (before next)

      mod::API = ::Module.new
      mod::API.send :define_singleton_method, :application_kernel_, -> do
        ak = bz::Kernel.new mod
        -> do
          ak
        end
      end.call

      model = ::Module.new

      mod::Models_::No_See = model

      model::Actions = ::Module.new

      cls = ::Class.new bz::Action

      model::Actions::Shanoozle = cls

      cls.is_promoted = true

      cls
    end

    def subject_module_
      Home_::Models_::Reactive_Model_Dispatcher
    end

    def init_front_with_box_ fr, bx

      fr.fast_lookup = -> nf do
        bx[ nf.as_lowercase_with_underscores_symbol ]
      end

      fr.unbound_stream_builder = -> do
        bx.to_value_stream
      end
      NIL_
    end
  end
    end  # if false

    # ==

    GENERIC_PARSE_ERROR_CHANNEL___ =  [ :error, :expression, :parse_error ]

    # ==
# ->
  end
end
