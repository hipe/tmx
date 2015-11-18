module Skylab::Brazen

  class CLI

    class When_::Help < As_Bound_Call_

      def initialize cmd_s, help_renderer, action_adapter

        @aa = action_adapter
        @any_cmd_string = cmd_s
        @help_renderer = help_renderer
      end

      def produce_result
        if @any_cmd_string
          __when_command_string
        else
          __when_no_command_string
        end
      end

      def __when_command_string

        aa = @aa
        a = aa.find_matching_action_adapters_against_tok_ @any_cmd_string

        case 1 <=> a.length
        when  0

          a.first.receive_show_help_ @help_renderer.action_adapter

        when  1
          aa.receive_no_matching_via_token__ @any_cmd_string

        when -1
          aa.receive_multiple_matching_via_adapters_and_token__ a, @any_cmd_string
        end
      end

      def __when_no_command_string

        aa = @aa
        o = @help_renderer


        # ~ usage line

        o.express_usage_


        # ~ description section

        if aa.has_description
          o.express_description_
        end


        # ~ actions section

        o.section_boundary
        o.express_header_ 'actions'
        o.express_option_parser_summary_  # sic

        _visible_st = aa.to_adapter_stream_.reduce_by( & :is_visible )

        _ordered_st = aa.wrap_adapter_stream_with_ordering_buffer_ _visible_st

        item_a = _ordered_st.to_a

        if item_a.length.zero?

          o.express do
            "(no actions)"
          end

          GENERIC_ERROR_EXITSTATUS
        else
          __when_nonzero_items item_a, o
        end
      end

      def __when_nonzero_items item_a, o

        o = @help_renderer

        o.express_items_with_descriptions_ nil, item_a, 2

        # ~ invite to more help

        o.section_boundary

        aa = @aa
        prp = aa.properties.fetch :action
        o.express do
          "use #{ code "#{ aa.invocation_string } -h #{
            }#{ par prp }" } for help on that action."
        end

        SUCCESS_EXITSTATUS
      end
    end
  end
end
