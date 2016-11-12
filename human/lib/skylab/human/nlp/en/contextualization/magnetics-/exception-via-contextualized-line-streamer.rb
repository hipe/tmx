module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Exception_via_Contextualized_Line_Streamer

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        alias_method :[], :via_magnetic_parameter_store
        private :new
      end  # >>

      def initialize ps
        @parameter_store = ps
      end

      def execute

        cls = @parameter_store.exception_class
        if ! cls
          cls = __exception_class_derived_from_channel
          if ! cls
            cls = ::RuntimeError
          end
        end

        cls.new __message
      end

      def __message

        buffer = ""
        st = @parameter_store.contextualized_line_streamer.call
        while line = st.gets
          buffer << line
        end
        buffer.chomp!  # exception messages typically don't end in newlines
        buffer
      end

      def __exception_class_derived_from_channel

        sym = @parameter_store.channel[ 2 ]
        if sym
          Common_::Event::To_Exception::Class_via_symbol.call sym do
            NOTHING_
          end
        end
      end
    end
  end
end
# #history: abstracted from core at switch advent
