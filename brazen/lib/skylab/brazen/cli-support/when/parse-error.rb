module Skylab::Brazen

  module CLI_Support

    class When::Parse_Error < As_Bound_Call

      # (typically used to express the expression raised by stdlib o.p)

      def initialize message, invocation_expression

        @_expression = invocation_expression
        @_message = message
      end

      def produce_result

        o = @_expression
        o.line_yielder << @_message
        o.express_invite_to_general_help :because, :option
        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
