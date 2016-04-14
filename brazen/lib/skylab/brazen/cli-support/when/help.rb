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

      def _express_common_screen

        @invocation_expression.express_usage_section

        @invocation_expression.express_description

        @invocation_expression.express_custom_sections

        @_do_options_as_actions = @invocation_expression.do_express_options_as_actions_for_help

        express_items_
      end
    end

    class When::Help::For_Branch < When::Help

      def produce_result

        if @command_string
          ___when_command_string
        else
          _express_common_screen
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

        if ! @_do_options_as_actions
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
          @invocation_expression.express_invite_to_help_as_compound_to @invocation_reflection
          SUCCESS_EXITSTATUS
        else
          GENERIC_ERROR_EXITSTATUS  # ..
        end
      end

      def ___express_action_items_into y, ada_a

        exp = @invocation_expression
        expag = exp.expression_agent

        if @_do_options_as_actions
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
    end

    class When::Help::For_Action < When::Help

      def produce_result
        _express_common_screen
      end

      def express_items_

        ___express_options

        express_any_custom_sections_  # result is t/f of any

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
    end

    class When::Help

      def express_any_custom_sections_

        intr = nil

        p = -> xx_aa do
          intr = Here_::Section::DSL.new @invocation_expression
          p = -> x_a do
            intr.receive x_a
          end
          p[ xx_aa ]
        end

        @invocation_reflection.custom_sections do |*x_a|
          p[ x_a ]
        end

        if intr
          intr.finish  # result is t/f of any
        else
          NOTHING_
        end
      end
    end
  end
end
