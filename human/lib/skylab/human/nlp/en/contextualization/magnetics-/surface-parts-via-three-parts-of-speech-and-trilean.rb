module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Surface_Parts_via_Three_Parts_Of_Speech_and_Trilean

      class << self

        def via_magnetic_parameter_store ps
          new( ps ).execute
        end

        private :new
      end  # >>

      def initialize ps

        @on_failed_proc = ps.on_failed_proc
        @trilean = ps.trilean
        @three_parts_of_speech = ps.three_parts_of_speech
      end

      def execute
        x = @trilean
        send ( if x
          :__when_successful
        elsif x.nil?
          :__when_neutral
        else
          :__when_failed
        end )
      end

      def __when_failed

        p = @on_failed_proc
        if p
          sp = Models_::Surface_Parts.begin_via_parts_of_speech @three_parts_of_speech
          p[ sp, @three_parts_of_speech ]
          sp
        else
          _go :Surface_Parts_via_Three_Parts_Of_Speech_when_Failed_Classically
        end
      end

      def __when_neutral
        _go :Surface_Parts_via_Three_Parts_Of_Speech_when_Neutral_Classically
      end

      def __when_successful
        _go :Surface_Parts_via_Three_Parts_Of_Speech_when_Successful_Classically
      end

      def _go const
        Magnetics_.const_get( const, false )[ @three_parts_of_speech ]
      end
    end
  end
end
# #history: broke out of sibling file
