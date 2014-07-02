module Skylab::Brazen

  module CLI

    class State_Processors_::When_Help

      def initialize option_parser, cmd, client
        @any_cmd_string = cmd
        @column_one_width = 20
        @client = client
        @expression_agent = client.expression_agent
        @format_string = "%#{ @column_one_width }s     %s"
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
        client = @client ; option_parser = @option_parser
        me = self ; out = @out ; column_one_width = @column_one_width
        @expression_agent.calculate do
          out.puts client.usage_line
          out.puts "#{ hdr "actions" }"
          option_parser.summarize nil, column_one_width do |line|
            out.puts line
          end
          me.rndr_actions
          out.puts "use #{ code "#{ client.invocation_string } -h #{
            }<action>" } for help on that action."
        end
        GENERIC_SUCCESS__
      end
      GENERIC_SUCCESS__ = 0

      def rndr_actions
        scn = @client.get_visible_action_scanner
        while (( action = scn.gets ))
          rndr_action action
        end ; nil
      end ; public :rndr_actions

      def rndr_action action
        fmt = @format_string
        @out.puts( @expression_agent.calculate do
          fmt % [ action.name.as_slug, action.one_line_description ]
        end ) ; nil
      end
    end
  end
end
