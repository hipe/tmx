module Skylab::Brazen

  module CLI

    class State_Processors_::When_No_Matching_Action

      def initialize token, client
        @client = client ; @token = token
      end

      def execute
        client = @client ; out = @client.stderr
        scn = @client.get_visible_action_scanner
        token = @token
        @client.expression_agent.calculate do
          out.puts "unrecognized action #{ ick token }"
          out.write "known actions are ("
          action = scn.gets and out.write code action.name.as_slug
          while (( action = scn.gets ))
            out.write ", #{ code action.name.as_slug }"
          end
          out.puts ")"
          out.puts client.invite_to_general_help_line
        end
        GENERIC_ERROR_
      end
    end
  end
end
