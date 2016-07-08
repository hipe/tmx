module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Expression_via_Contextualized_Line_Stream ; class << self

      def via_magnetic_parameter_store ps

        st = ps.contextualized_line_stream
        y = ps.line_yielder

        begin
          s = st.gets
          s || break
          y << s
          redo
        end while nil

        y
      end

    end ; end
  end
end
# #history: abstracted from core, as first semi-real magnet
