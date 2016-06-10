module Skylab::DocTest

  class Magnetics_::SpanStream_via_CommentBlock < Common_::Actor::Monadic
    # -
      def initialize cb

        @comment_block = cb

        @current_flush_method_name = @next_flush_method_name = nil
        @state = STATE_MACHINE__.fetch :beginning_state
        @local_margin_d = 0
          # the number of spaces in from beginning of of the comment content
          # line - is sticky from text span to code span
        @is_reading = true
      end

      def execute
        Common_.stream( & method( :produce_node ) )
      end

      def produce_node

        if @is_reading
          @do_stay = true

          begin
            md = @comment_block.gets
            if ! md
              @is_reading = false
              break
            end
            @comment_content_line = md.post_match
            process_comment_content_line
            @do_stay or break
            redo
          end while nil
        end

        if @current_flush_method_name
          i = @current_flush_method_name
          @current_flush_method_name = @next_flush_method_name
          @next_flush_method_name = nil
          send i
        end
      end

      def process_comment_content_line
        @md_for_leading_whitespace = HOW_MUCH_LEADING_SPACE_RX__.match @comment_content_line
        @md_for_list_item = MARKDOWN_LIST_STARTER_ESQUE_RX__.match @md_for_leading_whitespace.post_match
        if @md_for_list_item
          send @state.method_name_for_state :list_line
        elsif @md_for_leading_whitespace.post_match.length.zero?
          send @state.method_name_for_state :blank_line
        else
          when_not_blank
        end
      end

      HOW_MUCH_LEADING_SPACE_RX__ = /\A[[:space:]]*/

      MARKDOWN_LIST_STARTER_ESQUE_RX__ = /\A(?:•|-|\+|\*)[[:space:]]*/

      o = State_

      STATE_MACHINE__ = {

        beginning_state: o[
          blank_line: :ignore_blank_line,
          code_line: :begin_code_span,
          list_line: :begin_text_span_and_process_markdown_esque_list_item,  # #todo
          text_line: :begin_text_span ],

        code_span_state: o[
          blank_line: :accept_line_into_current_code_span,
          code_line: :accept_line_into_current_code_span,
          list_line: :accept_line_into_current_code_span,
          text_line: :finish_code_span_and_begin_text_span ],

        text_span_state: o[
          blank_line: :ignore_blank_line,
          code_line: :finish_text_span_and_begin_code_span,
          list_line: :process_markdown_esque_list_item,
          text_line: :accept_line_into_current_text_span ] }

      def ignore_blank_line
      end

      def when_not_blank
        _CCL_leading_whitespace_amount = @md_for_leading_whitespace[ 0 ].length
        @local_indent_amount = _CCL_leading_whitespace_amount - @local_margin_d
        if @local_indent_amount < FOUR__
          send @state.method_name_for_state :text_line
        else
          send @state.method_name_for_state :code_line
        end
      end

      FOUR__ = 4

      # ~ markdown list item

      def process_markdown_esque_list_item

        @local_margin_d = @md_for_leading_whitespace[ 0 ].length +
          @md_for_list_item[ 0 ].length

        # it is the first content character (if any) of the list item that
        # determines the new local margin

        @text_rotbuf << @md_for_list_item.post_match

        # experimentally we ditch the list item glyph here and now but this
        # might chnage.

        nil
      end

      # ~ text

      def begin_text_span
        @text_rotbuf = Home_.lib_.basic::RotatingBuffer.new TWO__
        @next_flush_method_name = :flush_active_text_span
        accept_line_into_current_text_span
        @state = STATE_MACHINE__.fetch :text_span_state
        nil
      end

      TWO__ = 2

      def accept_line_into_current_text_span

        @local_margin_d = @md_for_leading_whitespace[ 0 ].length

        # whether indenting or de-denting or staying the same, whatever the
        # indent is of this # text line is (within the CCL) establishes the
        # new local indent (which may or may not be different than before)

        @text_rotbuf << @md_for_leading_whitespace.post_match

        nil
      end

      def finish_text_span_and_begin_code_span
        @do_stay = false
        @current_flush_method_name = :flush_active_text_span
        begin_code_span
      end

      def flush_active_text_span
        x = Text_Span__.new @text_rotbuf.to_a
        @text_rotbuf = nil
        x
      end

      # ~ code

      def begin_code_span
        @code_line_a = []
        @next_flush_method_name = :flush_active_code_span
        accept_line_into_current_code_span
        @state = STATE_MACHINE__.fetch :code_span_state
        nil
      end

      def accept_line_into_current_code_span

        line = @comment_content_line[ ( @local_margin_d + FOUR__ ) .. -1 ]
        line ||= NEWLINE_  # assume it's because blank line was short

        @code_line_a.push line

        nil
      end

      def finish_code_span_and_begin_text_span
        @do_stay = false
        @current_flush_method_name = :flush_active_code_span
        begin_text_span
      end

      def flush_active_code_span
        x = Code_Span__.new @code_line_a
        @code_line_a = nil
        x
      end

      class Span__
        def initialize a
          @a = a
        end
        attr_reader :a
      end

      class Text_Span__ < Span__
        def span_symbol
          :text_span
        end
      end

      class Code_Span__ < Span__
        def span_symbol
          :code_span
        end
      end
    # -
  end
end
