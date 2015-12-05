module Skylab::Brazen

  module CLI_Support

    class When::Extra_Arguments < As_Bound_Call

      def initialize x, invocation_expression

        @_expression = invocation_expression
        @_x = x
      end

      def produce_result

        o = @_expression
        x = @_x

        o.express do
          "unexpected argument #{ ick x }"
        end

        o.express_primary_usage_line

        o.express_invite_to_general_help :because, :argument

        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
