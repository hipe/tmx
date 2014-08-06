module Skylab::Brazen

  module CLI

    class When_::No_Matching_Action

      def initialize token, help_renderer, action_adapter
        @aa = action_adapter
        @render = help_renderer
        @token = token
      end

      def execute
        o = @render ; token = @token
        scn = @aa.actions.visible.get_scanner
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
