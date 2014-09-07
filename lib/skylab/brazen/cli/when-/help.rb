module Skylab::Brazen

  class CLI

    class When_::Help < Simple_Bound_Call_

      def initialize cmd_s, help_renderer, action_adapter
        @aa = action_adapter
        @any_cmd_string = cmd_s
        @help_renderer = help_renderer
      end

      def produce_any_result
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
        case 1 <=> a.length
        when  0 ; a.first.receive_show_help @help_renderer.invocation
        when  1 ; aa.receive_no_matching_action @any_cmd_string
        when -1 ; aa.receive_multiple_matching_adapters a
        end
      end

      def whn_no_command_string
        o = @help_renderer ; aa = @aa
        o.output_usage

        aa.has_description and o.output_description

        o.section_boundary
        o.output_header 'actions'
        o.output_option_parser_summary  # sic
        _scn = aa.get_action_scn.reduce_by( & :is_visible )
        _scn = aa.wrap_scanner_with_ordering_buffer _scn
        o.output_items_with_descriptions nil, _scn.to_a, 2
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
