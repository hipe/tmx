module Skylab::Brazen

  module CLI_Support

    class When::No_Matching_Action < As_Bound_Call

      def initialize token, invocation_expression, invocation_reflection

        @_reflection = invocation_reflection
        @_expression = invocation_expression
        @_token = token
      end

      def produce_result

        o = @_expression
        token = @_token

        _scn = @_reflection.to_adapter_stream_.reduce_by( & :is_visible )

        scn = @_reflection.wrap_adapter_stream_with_ordering_buffer_ _scn

        o.express do
          "unrecognized action #{ ick token }"
        end

        s_a = []
        ad = scn.gets
        while ad
          s_a.push( o.expression_agent.calculate do
            code ad.name.as_slug
          end )
          ad = scn.gets
        end

        o.line_yielder << "known actions are (#{ s_a * ', ' })"

        o.express_invite_to_general_help

        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
