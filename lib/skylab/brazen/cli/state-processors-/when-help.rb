module Skylab::Brazen

  module CLI

    class State_Processors_::When_Help

      def initialize option_parser, cmd, client
        @any_cmd_string = cmd
        @client = client
        @expression_agent = client.expression_agent
        @option_parser = option_parser
        @out = client.stderr
      end

      def execute
        if @any_cmd_string
          when_command_string
        else
          when_no_command_string
        end
      end

    private

      def when_no_command_string
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
    end
  end
end
