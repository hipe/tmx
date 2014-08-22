module Skylab::Brazen

  class CLI

    class When_::No_Matching_Action < Simple_Executable_

      def initialize token, help_renderer, invo
        @invo = invo
        @render = help_renderer
        @token = token
      end

      def execute
        o = @render ; token = @token
        scn = @invo.get_action_scn.reduce_by( & :is_visible )
        o.express { "unrecognized action #{ ick token }" }
        s_a = []
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
