module Skylab::Brazen

  module CLI_Support

    class When::Help < As_Bound_Call  # abstract

      def initialize
        @command_string = nil
      end

      attr_writer(
        :command_string,
        :invocation_expression,
        :invocation_reflection,
      )

      def express_common_screen_

        @invocation_expression.express_usage_section

        @invocation_expression.express_description

        @_options_as_actions = @invocation_expression.express_options_as_actions_for_help

        express_items_
      end
    end

    class When::Help::For_Branch < When::Help

      def produce_result

        if @command_string
          ___when_command_string
        else
          express_common_screen_
        end
      end

      def ___when_command_string

        o = @invocation_reflection

        a = o.find_matching_action_adapters_against_tok_(
          @command_string )

        case 1 <=> a.length
        when  0
          a.first.receive_show_help o

        when  1
          o.receive_no_matching_via_token__ @command_string

        when -1
          o.receive_multiple_matching_via_adapters_and_token__(
            a, @command_string )
        end
      end

      def express_items_  # actions

        # when options are expressed separate from actions they are expressed
        # *after* the actions by the justification that they are generally
        # more detailed and low-level. note that it is always the expression
        # of actions that determines the exitstatus (for now).

        es = ___express_actions

        if ! @_options_as_actions
          __express_branch_options
        end

        es
      end

      def ___express_actions  # result is exitstatus

        ada_a = ___arrange_items

        if ada_a.length.zero?
          __when_no_actions
        else
          __when_some_actions ada_a
        end
      end

      def __express_branch_options

        exp = @invocation_expression
        op = exp.option_parser
        if op
          _s = exp.plural_options_section_header_label_for_help
          exp.express_section(
            :header, _s,
            :singularize,  # not working, but meh
          ) do |y|
            op.summarize y
          end
        end
        NIL_
      end

      def ___arrange_items

        o = @invocation_reflection

        _visible_st = o.to_adapter_stream.reduce_by( & :is_visible )

        _ordered_st = o.wrap_adapter_stream_with_ordering_buffer _visible_st

        _ordered_st.to_a
      end

      def __when_no_actions

        @invocation_expression.express_section do |y|
          y << "(no actions)"
        end

        GENERIC_ERROR_EXITSTATUS  # ..
      end

      def __when_some_actions ada_a

        Require_fields_lib_[]

        exp = @invocation_expression

        did = exp.express_section(
          :header, 'actions',
          :singularize,
          :wrapped_second_column, exp.option_parser,
        ) do | y |
          ___express_action_items_into y, ada_a
        end

        if did
          __invite_to_more_help
          SUCCESS_EXITSTATUS
        else
          GENERIC_ERROR_EXITSTATUS  # ..
        end
      end

      def ___express_action_items_into y, ada_a

        exp = @invocation_expression
        expag = exp.expression_agent

        if @_options_as_actions
          # present the 'help' option (or whatever) as an action
          op = exp.option_parser
          if op
            op.summarize y
          end
        end

        ada_a.each do | ada |

          if Field_::Has_description[ ada ]

            # #[#002]an-optimization-for-summary-of-child-under-parent

            _p = ada.description_proc_for_summary_under exp

            _desc_lines = Field_::N_lines_via_proc[ MAX_DESC_LINES, expag, _p ]
          end

          y.yield ada.name.as_slug, ( _desc_lines || EMPTY_A_ )
        end
        NIL_
      end

      def __invite_to_more_help

        exp = @invocation_expression
        _prp = @invocation_reflection.properties.fetch :action
        _s =  @invocation_reflection.subprogram_name_string

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

        st = @invocation_reflection.to_section_stream
        if st
          __express_other_sections st
        end

        SUCCESS_EXITSTATUS
      end

      def ___express_options

        op = @invocation_reflection.option_parser
        if op

          _ = 1 == op.top.list.length ? 'option' : 'options'

          @invocation_expression.express_section :header, _ do | y |
            op.summarize y
          end
        end
        NIL_
      end

      def __express_other_sections st

        exp = @invocation_expression

        expag = exp.expression_agent
        _NUM_LINES = Home_::CLI_Support::MAX_DESC_LINES

        begin
          section = st.gets
          section or break

          _section_name_function = section.name_x
          item_stream = section.value_x

          @invocation_expression.express_section(
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
