module Skylab::TestSupport

  module DocTest

    class Intermediate_Streams_::Node_stream_via_comment_block_stream::Node_stream_via_span_stream__

      Callback_::Actor.call self, :properties,
        :span_stream

      def execute
        @state_machine = STATE_MACHINE__
        @state = @state_machine.fetch :beginning_state
        Callback_.stream do
          @do_stay = true
          @flush_method_name = nil
          @result = nil
          @span = @span_stream.gets
          @eg_a = nil
          while @span
            send @state.method_name_for_state @span.span_symbol
            @do_stay or break
            @span = @span_stream.gets
          end
          if @flush_method_name
            i = @flush_method_name ; @flush_method_name = nil
            @result = send i
          end
          @result
        end
      end

      o = State_

      STATE_MACHINE__ = {

        beginning_state: o[
          code_span: :ignore,
          text_span: :when_first_text_span ],

        after_first_text_span: o[
          code_span: :when_first_code_span ],

        after_ancillaries: o[
          text_span: :when_text_span_for_example_in_context ],

        after_text_for_example_in_context: o[
          code_span: :when_code_span_for_example_in_context ],

        after_bare_example: o[
          text_span: :when_intermediate_text_span ]
      }

      def ignore
        nil
      end

      def when_first_text_span
        @text_span = @span
        @state = @state_machine.fetch :after_first_text_span
        nil
      end

      def when_text_span_for_example_in_context
        @text_span = @span
        @state = @state_machine.fetch :after_text_for_example_in_context
        nil
      end

      def when_first_code_span
        matchdata = First_Code_Span__.match @span
        if matchdata.is_ancillary_nodes
          when_ancillary_nodes matchdata
        else
          when_code_span_for_bare_example matchdata
        end
      end

      def when_code_span_for_bare_example example_md
        @do_stay = false
        @result = Intermediate_Streams_::Models_::Example_Node.build(
          @text_span, example_md )
        @state = @state_machine.fetch :after_bare_example
        nil
      end

      def when_code_span_for_example_in_context

        example_md = Example_Code_Span__.match @span
        @span = nil

        if example_md
          _eg = Intermediate_Streams_::Models_::Example_Node.build(
            @text_span, example_md )
          @eg_a ||= []
          @eg_a.push _eg
        end

        @state = @state_machine.fetch :after_ancillaries

        nil
      end

      def when_ancillary_nodes matchdata
        @anc_nodes = matchdata
        @flush_method_name = :flush_context_node
        @state = @state_machine.fetch :after_ancillaries
        nil
      end

      def flush_context_node
        if @eg_a
          a = @anc_nodes.flush_mutable_node_array
          @anc_nodes = nil
          a.concat @eg_a
          @eg_a = nil
          Intermediate_Streams_::Models_::Context.build @text_span, a
        else
          # :+#[#037] warnings wishlist
          nil
        end
      end

      class Example_Code_Span__

        class << self
          def match span
            new( span ).produce_matchdata
          end
        end

        def initialize x
          @span = x
        end

        def produce_matchdata
          @scn = TestSupport_::Lib_::Bsc[]::List.line_stream @span.a
          @line = @scn.rgets
          when_first_line
          matchdata_via_looking_at_every_remaining_line
        end

        def when_first_line
        end

        def matchdata_via_looking_at_every_remaining_line
          @num_non_let_lines = @scn.remaining_count + 1
          @topmost_content_line = nil

          while @line

            if BLANK_RX_ =~ @line
              @line = @scn.rgets
              next
            end

            @topmost_content_line = @line

            md = Intermediate_Streams_::Models_::Predicate_Expressions.match @line
            if md
              predicate_was_found = true
              break
            end

            @line = @scn.rgets
          end

          if predicate_was_found
            matchdata_when_predicate_found md
          else
            matchdata_when_predicate_not_found
          end
        end

        def matchdata_when_predicate_found md
          Intermediate_Streams_::Models_::Example_Node::Matchdata.new md, @scn, @span
        end

        def matchdata_when_predicate_not_found
          nil  # when no predicate in a non-first code block, ignore
        end
      end

      class First_Code_Span__ < Example_Code_Span__

        # every first qualified code span in a comment block classifies
        # into one of three classifications:
        #
        #   • example
        #   • before all [ let [ let [..]]
        #   • before each [ let [ let [..]]

        # because we define "let" expressions as occuring in a trailing
        # manner contiguously at the end of the span, we will parse the
        # whole thing "backwards" up from the end.

        # blank lines are always ignored

        # if at any point you find a predicate "magic sequence" anywhere
        # in the span, this immediately disqualifies it for anything other
        # than an example. (still you may want to parse for all such lines
        # somehow.) otherwise when you don't find one anywhere, this
        # span will always be classified as one kind of "before" node
        # (perhaps with "let" nodes).

        # once you find anything other than a let assignment up from
        # the end, you are no longer looking for let assignments.

        # memoize each last content (that is, non-blank) line as you look
        # at each line. when you get to the last one (which because we went
        # backwards is the topmost line), the way this line looks will
        # determine whether this is a "before each" or "before all".

        def when_first_line
          init_let_line_matchdata_array
        end

        def init_let_line_matchdata_array
          @let_line_md_a = nil

          while @line

            if BLANK_RX_ =~ @line
              @line = @scn.rgets
              next
            end

            md = Intermediate_Streams_::Models_::Let_Assignment.match @line

            if md
              @let_line_md_a ||= []
              @let_line_md_a.push md
              @line = @scn.rgets
              next
            end

            break
          end
        end

        def matchdata_when_predicate_not_found
          Ancillary_Nodes__.new @topmost_content_line, @num_non_let_lines, @let_line_md_a, @span
        end
      end

      class Ancillary_Nodes__

        def initialize * a
          @topmost_content_line, @num_non_let_lines, @let_line_md_a, @span = a
        end

        def is_ancillary_nodes
          true
        end

        def flush_mutable_node_array
          a = []

          if @topmost_content_line

            _before_lines = @span.a[ 0, @num_non_let_lines ]

            a.push Intermediate_Streams_::Models_::Before_Node.build(
              @topmost_content_line, _before_lines )
          end

          if @let_line_md_a
            @let_line_md_a.each do |md|
              let = Intermediate_Streams_::Models_::Let_Assignment.build md
              let and a.push let
            end
          end

          a
        end
      end
    end
  end
end
