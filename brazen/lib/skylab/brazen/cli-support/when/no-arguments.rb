module Skylab::Brazen

  module CLI_Support

    class When::No_Arguments < As_Bound_Call

      def initialize prp, invocation_expression

        @_expression = invocation_expression
        @_property = prp
      end

      def produce_result

        o = @_expression
        prp = @_property

        o.express do
          "expecting #{ par prp }"
        end

        o.express_primary_usage_line

        o.express_invite_to_general_help :because, :argument

        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
