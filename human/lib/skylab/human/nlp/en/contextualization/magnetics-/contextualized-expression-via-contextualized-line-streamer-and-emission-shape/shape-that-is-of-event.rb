module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Contextualized_Expression_via_Contextualized_Line_Streamer_and_Emission_Shape::Shape_that_Is_Of_Event < Magnet_

      def execute

        ps = @ps_
        @__channel = ps._read_magnetic_value_with_certainty_ :channel
        @__contextualized_line_streamer = ps._read_magnetic_value_with_certainty_ :contextualized_line_streamer
        @__structured_event = ps.possibly_wrapped_event.to_event  # disregard any wrapping

        p = ps.downstream_selective_listener_proc
        if p
          @__listen_proc = p
          __build_and_emit_new_event
        else
          __express_lines_now
        end
      end

      def __build_and_emit_new_event

        _ev = __build_new_event
        @__listen_proc.call( * @__channel ) do
          _ev
        end
        UNRELIABLE_
      end

      def __build_new_event

        me = self
        @__structured_event.new_with do |y, _o|
          me._flush_contextualized_lines_into y
          UNRELIABLE_
        end
      end

      def __express_lines_now

        y = @ps_._read_magnetic_value_with_certainty_ :line_yielder
        _flush_contextualized_lines_into y
        y
      end

      def _flush_contextualized_lines_into y

        st = @__contextualized_line_streamer.call
        while line = st.gets
          y << line
        end
        NIL_
      end
    end
  end
end
# #history: born.
