module Skylab::Brazen

  module CLI_Support

    class When::Help < As_Bound_Call  # (fwd declaration)
#==FROM

      # (at writing used only by [tmx] only for [ze] "argument scanner" related) (etc)

      ScreenForWhichever__ = ::Class.new

      class ScreenForBranch < ScreenForWhichever__

        def operation_normal_symbol_stream st
          @items_section_label = "operations"
          receive_item_stream Operation_name_via_symbol__, st
          NIL
        end

        def primary_normal_symbol_stream st
          @items_section_label = "primaries"
          receive_item_stream Primary_name_via_symbol__, st
          NIL
        end

        def express_usage_section program_name

          @express_boundary[]

          buffer = "usage: #{ program_name }"
          st = to_node_name_stream
          one = st.gets
          if one
            buffer << " { " << one.as_slug
            begin
              nm = st.gets
              nm || break
              buffer << PIPEY___ << nm.as_slug
              redo
            end while above
            buffer << " }"
          end
          buffer << " [opts]"
          @puts.call buffer
          NIL
        end
      end

      class ScreenForEndpoint < ScreenForWhichever__

        def primary_normal_symbol_stream st
          @items_section_label = "primaries"
          receive_item_stream Primary_name_via_symbol__, st
          NIL
        end

        def express_usage_section program_name

          @express_boundary[]

          buffer = "usage: #{ program_name }"

          countdown = 3  # max number of primaries to show up here
          st = to_node_name_stream
          nm = st.gets

          if nm && countdown.nonzero?
            say = -> name do
              "[ #{ name.as_slug } ..]"
            end
            begin
              countdown -= 1
              buffer << SPACE_ << say[ nm ]
              nm = st.gets
              nm || break
              if countdown.zero?
                buffer << " .."
                break
              end
              redo
            end while above
          end
          @puts.call buffer
          NIL
        end
      end

      class ScreenForWhichever__

        class << self
          def express_into io
            yield new io
          end
          private :new
        end  # >>

        def initialize io

          puts = io.method :puts

          @express_boundary = -> do
            @express_boundary = puts ; nil
          end

          @express_blank_line = puts
          @puts = puts
        end

        def express_description_section_by & user_p
          express_description_section user_p
        end

        def express_description_section user_p
          express_section_simply_via_header_and_message_proc "description", user_p
        end

        def express_items_section_by & p
          express_items_section p
        end

        def express_items_section description_proc_for

          # (catalyzes the rendering of the items section)

          @express_boundary[]

          puts = @puts

          puts.call "#{ @items_section_label }:"

          two_spaces = "  "

          fmt = "#{ two_spaces }%#{ @max_name_width }s"

          indent_with_spaces = fmt % nil

          subsequent_line = -> line do
            puts.call "#{ indent_with_spaces }#{ two_spaces }#{ line }"
          end

          buffer = ""
          p = nil

          first_line = -> line do
            buffer << two_spaces
            buffer << line
            puts.call buffer
            p = subsequent_line
          end

          y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end

          item = -> nm do

            buffer = fmt % nm.as_slug

            desc_p = description_proc_for[ nm.as_variegated_symbol ]
            if desc_p
              p = first_line
              desc_p[ y ]
            end
            NIL
          end

          subsequent_boundary = -> do
            buffer.clear
            @express_blank_line[]
          end

          boundary = -> do
            boundary = subsequent_boundary
          end

          st = to_node_name_stream
          begin
            nm = st.gets
            nm || break
            boundary[]
            item[ nm ]
            redo
          end while nil
          NIL
        end

        def express_section_simply_via_header_and_message_proc hdr, msg_p

          @express_boundary[]

          p = -> line do
            p = @puts
            @puts.call "#{ hdr }: #{ line }"
          end

          _y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end

          msg_p[ _y ]
          NIL
        end
        private :express_section_simply_via_header_and_message_proc

        # -- write-on-receive (then read)

        def receive_item_stream name_via_normal_symbol, st

          a = []
          max = 0
          begin
            sym = st.gets
            sym || break
            name = name_via_normal_symbol[ sym ]
            len = name.as_slug.length
            max = len if max < len
            a.push name
            redo
          end while above
          @max_name_width = max
          @names = a
          NIL
        end
        private :receive_item_stream

        def to_node_name_stream
          Stream_[ @names ]
        end
      end

      # ==

      Primary_name_via_symbol__ = -> sym do
        nm = Common_::Name.via_variegated_symbol sym
        nm.as_slug = "-#{ nm.as_slug }"
        nm
      end

      Operation_name_via_symbol__ = -> sym do
        Common_::Name.via_variegated_symbol sym
      end

      # ==

      Stream_ = -> a, & p do  # ..
        Common_::Stream.via_nonsparse_array a, & p
      end

      # ==

      PIPEY___ = ' | '
#==TO
    end

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
