module Skylab::Brazen

  class CLI

    class When_::No_Matching_Action < Simple_Bound_Call_

      def initialize token, help_renderer, invo
        @invo = invo
        @render = help_renderer
        @token = token
      end

      def produce_result

        o = @render
        token = @token

        _scn = @invo.to_adapter_stream.reduce_by( & :is_visible )

        scn = @invo.wrap_adapter_stream_with_ordering_buffer_ _scn

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

        o.y << "known actions are (#{ s_a * ', ' })"

        o.output_invite_to_general_help

        GENERIC_ERROR_
      end
    end
  end
end
