module Skylab::Brazen

  module CLI

    class When_::Help

      def initialize option_parser, cmd, client
        @any_cmd_string = cmd
        @client = client
        @expression_agent = client.expression_agent
        @option_parser = option_parser
        @out = client.stderr
      end

      def execute
        if @any_cmd_string
          whn_command_string
        else
          whn_no_command_string
        end
      end

    private

      def whn_no_command_string
        o = @o = @client.help_renderer
        o.set_option_parser @option_parser
        o.section_boundary
        o.output_usage_line
        o.section_boundary
        o.output_header 'actions'
        o.output_option_parser_summary
        o.output_items_with_descriptions nil, @client.actions.visible.to_a, 2
        o.section_boundary
        client = @client ; o.express do
          "use #{ code "#{ client.invocation_string } -h #{
            }<action>" } for help on that action."
        end
        SUCCESS_
      end

      def whn_command_string
        a = @client.find_matching_actions_with_token @any_cmd_string
        case a.length
        when 0 ; @client.invoke_when_no_matching_action
        when 1 ; @action = a.first ; whn_action
        else   ; @client.invoke_when_ambiguous_matching_actions
        end
      end

      def whn_action
        @action.invoke_via_argv [ '--help' ]
      end
    end
  end
end
