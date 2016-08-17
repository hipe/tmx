module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Inflected_Parts_via_Lemmas_and_Trilean  # 1x

      class << self

        def via_magnetic_parameter_store ps
          new( ps ).execute
        end

        private :new
      end  # >>

      def initialize ps
        @_ps = ps
      end

      def execute

        ps = @_ps

        @_lemmas = ps.lemmas

        if ! ps._magnetic_value_is_known_ :trilean
          # (hi.) [#043]
          if ps._magnetic_value_is_known_ :channel
            ps.trilean = Magnetics_::Trilean_via_Channel[ ps ]
          end
        end

        x = if ps._magnetic_value_is_known_ :trilean
          ps.trilean
        end

        send ( if x
          :__when_successful
        elsif x.nil?
          :__when_neutral
        else
          :__when_failed
        end )
      end

      def __when_failed

        p = @_ps.on_failed_proc
        if p
          ip = Models_::Inflected_Parts.begin_via_lemmas @_lemmas
          p[ ip, @_lemmas ]
          ip
        else
          _go :Inflected_Parts_via_Lemmas_and_Trilean_that_Is_Failure
        end
      end

      def __when_neutral
        _go :Inflected_Parts_via_Lemmas_and_Trilean_that_Is_Neutral
      end

      def __when_successful
        _go :Inflected_Parts_via_Lemmas_and_Trilean_that_Is_Success  # the only reference
      end

      def _go const
        Magnetics_.const_get( const, false )[ @_lemmas ]
      end
    end
  end
end
# #history: broke out of sibling file
