module Skylab::Brazen

  module CLI_Support

    class When::Help < As_Bound_Call  # abstract

      def initialize cmd_s, invocation_expression, invocation_reflection

        @_reflection = invocation_reflection
        @_expression = invocation_expression
        @_command_string = cmd_s
      end

      def express_common_screen_

        @_expression.express_usage_section

        @_expression.express_description

        express_items_
      end
    end

    class When::Help::For_Branch < When::Help

      def produce_result

        if @_command_string
          ___when_command_string
        else
          express_common_screen_
        end
      end

      def ___when_command_string

        o = @_reflection

        a = o.find_matching_action_adapters_against_tok_(
          @_command_string )

        case 1 <=> a.length
        when  0
          a.first.receive_show_help_ o

        when  1
          o.receive_no_matching_via_token__ @_command_string

        when -1
          o.receive_multiple_matching_via_adapters_and_token__(
            a, @_command_string )
        end
      end

      def express_items_  # actions

        ada_a = ___arrange_items

        if ada_a.length.zero?
          __when_no_actions
        else
          __when_some_actions ada_a
        end
      end

      def ___arrange_items

        o = @_reflection

        _visible_st = o.to_adapter_stream_.reduce_by( & :is_visible )

        _ordered_st = o.wrap_adapter_stream_with_ordering_buffer_ _visible_st

        _ordered_st.to_a
      end

      def ___when_no_actions

        @_expression.express do
          "(no actions)"
        end

        GENERIC_ERROR_EXITSTATUS  # ..
      end

      def __when_some_actions ada_a

        exp = @_expression
        expag = exp.expression_agent
        op = exp.option_parser

        did = exp.express_section(
          :header, 'actions',
          :singularize,
          :wrapped_second_column, exp.option_parser,

        ) do | y |

          op.summarize y
            # (present the 'help' option (or whatever) as an action)

          ada_a.each do | ada |

            if ada.has_description
              _desc_lines = ada.under_expression_agent_get_N_desc_lines(
                expag, MAX_DESC_LINES )
            end

            y.yield ada.name.as_slug, ( _desc_lines || EMPTY_A_ )
          end
        end

        if did
          ___invite_to_more_help
          SUCCESS_EXITSTATUS
        else
          GENERIC_ERROR_EXITSTATUS  # ..
        end
      end

      def ___invite_to_more_help

        exp = @_expression
        _prp = @_reflection.properties.fetch :action
        _s =  @_reflection.subprogram_name_string_

        exp.express_section do | y |

          exp.expression_agent.calculate do

            y << "use #{ code "#{ _s } -h #{
              }#{ par _prp }" } for help on that action."
          end
        end
        NIL_
      end
    end

    class When::Help::For_Action < When::Help

      def produce_result
        express_common_screen_
      end

      def express_items_

        ___express_options

        __express_non_options

        SUCCESS_EXITSTATUS
      end

      def ___express_options

        op = @_reflection.option_parser__
        if op

          _ = 1 == op.top.list.length ? 'option' : 'options'

          @_expression.express_section :header, _ do | y |
            op.summarize y
          end
        end
        NIL_
      end

      def __express_non_options

        exp = @_expression
        st = @_reflection.to_section_stream__

        expag = exp.expression_agent
        _NUM_LINES = Home_::CLI_Support::MAX_DESC_LINES

        begin
          section = st.gets
          section or break

          _section_name_function = section.name_x
          item_stream = section.value_x

          @_expression.express_section(
            :header, _section_name_function.as_human,
            :pluralize,
            :wrapped_second_column, exp.option_parser,
          ) do | y |

            begin
              item = item_stream.gets
              item or break

              _item_moniker_p = item.name_x
              _desc_lines_p = item.value_x

              _name_as_slug = _item_moniker_p[ expag ]

              _s_a = _desc_lines_p[ expag, _NUM_LINES ]

              y.yield( _name_as_slug, ( _s_a || EMPTY_A_ ) )

              redo
            end while nil
          end
          redo
        end while nil
        NIL_
      end
    end
  end
end
