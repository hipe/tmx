module Skylab::Brazen

  module CLI_Support

    class When::Multiple_Matching_Actions < As_Bound_Call

      def initialize adapter_a, token, invocation_expression

        @_adapter_array = adapter_a
        @_expression = invocation_expression
        @_token = token
      end

      def produce_result

        ae = @_expression

        _ev = Home_.lib_.fields::Events::Ambiguous.new(
          @_adapter_array, @_token, :action )

        _ev.express_into_under ae.line_yielder, ae.expression_agent

        ae.express_invite_to_general_help :because, :argument

        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end

