module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Exception_via_Contextualized_Line_Streamer ; class << self

      def via_magnetic_parameter_store ps

        buffer = ""
        st = ps.contextualized_line_streamer.call
        while line = st.gets
          buffer << line
        end
        buffer.chomp!  # exception messages typically don't end in newlines

        sym = ps.channel[ 2 ]
        cls = if sym
          Common_::Event::To_Exception::Class_via_symbol.call sym do
            NOTHING_
          end
        end
        cls ||= ::RuntimeError
        cls.new buffer
      end

      alias_method :[], :via_magnetic_parameter_store

    end ; end
  end
end
# #history: abstracted from core at switch advent
