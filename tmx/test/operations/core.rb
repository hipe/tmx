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

        define_method :realease_operations_call_array do
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

      def expect_parse_error_emission_lines_ * sym_a

        if sym_a.length.nonzero?
          _a = [ * GENERIC_PARSE_ERROR_CHANNEL___, * sym_a ]
        else
          _a = GENERIC_PARSE_ERROR_CHANNEL___
        end

        lines_via_this_kind_of_failure_via_array _a
      end

      def send_subject_call
        _x_a = realease_operations_call_array
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

    # ==

    GENERIC_PARSE_ERROR_CHANNEL___ =  [ :error, :expression, :parse_error ]

    # ==
# ->
  end
end
