module Skylab::Brazen

  module CLI_Support

    class When::Unhandled_Arguments < As_Bound_Call

      def initialize args, invocation_expression

        @_args = args
        @_expression = invocation_expression
      end

      def produce_result

        a = @_args

        @_expression.express do
          "(unhandled argument#{ s a }: #{ a * ', ' })"
        end

        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
