module Skylab::Brazen

  module CLI

    class When_::No_Matching_Action

      def initialize token, client
        @client = client ; @token = token
        @render = client.help_renderer
      end

      def execute
        o = @render
        scn = @client.actions.visible.get_scanner
        token = @token
        o.express { "unrecognized action #{ ick token }" }
        action = nil ; s_a = []
        while action = scn.gets
          s_a.push( o.expression_agent.calculate do
            code action.name.as_slug
          end )
        end
        o.y << "known actions are (#{ s_a * ', ' })"
        o.output_invite_to_general_help
        GENERIC_ERROR_
      end
    end
  end
end
