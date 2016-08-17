module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Contextualized_Expression_via_Contextualized_Line_Streamer_and_Emission_Shape::Shape_that_Is_Of_Expression ; class << self

      def via_magnetic_parameter_store ps

        p = ps.downstream_selective_listener_proc
        if p
          __emit_to_listener p, ps
        else
          __flush_lines ps
        end
      end

      def __emit_to_listener p, ps

        me = self

        p.call( * ps.channel ) do |y|

          me._flush_into y, ps
        end
      end

      def __flush_lines ps

        _flush_into ps.line_yielder, ps
      end

      def _flush_into y, ps

        st = ps.contextualized_line_streamer.call

        begin
          line = st.gets
          line || break
          y << line
          redo
        end while nil

        y
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: born.
