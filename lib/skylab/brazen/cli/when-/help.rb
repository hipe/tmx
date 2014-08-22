module Skylab::Brazen

  module CLI

    class When_::Help

      def initialize cmd_s, help_renderer, action_adapter
        @aa = action_adapter
        @any_cmd_string = cmd_s
        @help_renderer = help_renderer
      end

      def execute
        if @any_cmd_string
          whn_command_string
        else
          whn_no_command_string
        end
      end

    private

      def whn_command_string
        aa = @aa
        a = aa.find_matching_action_adapters_with_token @any_cmd_string
        case a.length
        when 0 ; aa.invoke_when_no_matching_action
        when 1 ; whn_action a.first
        else   ; aa.invoke_when_ambiguous_matching_actions
        end
      end

      def whn_action action
        action.adapter_via_argv [ '--help' ]  # nil
        SUCCESS_
      end

      def whn_no_command_string
        o = @help_renderer ; aa = @aa
        o.screen_boundary
        o.section_boundary
        o.output_usage_line
        o.section_boundary
        o.output_header 'actions'
        o.output_option_parser_summary
        _a = @aa.get_action_scn.reduce_by( & :is_visible ).to_a
        o.output_items_with_descriptions nil, _a, 2
        o.section_boundary
        prop = aa.properties.fetch :action
        o.express do
          "use #{ code "#{ aa.invocation_string } -h #{
            }#{ par prop }" } for help on that action."
        end
        SUCCESS_
      end
    end
  end
end
