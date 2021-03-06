module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    class Levels_::Annual < Here_::CommonLevel_

          class << self

            def next
              self._COVER_AND_DESIGN_ME
              :Singularity
            end

            def within_ sumzn

              within__ sumzn.downstream, sumzn.subject, sumzn.width
            end

            def within__ downstream, subject, width

              send :"__within__#{ width }__", downstream, subject
            end

            def __within__4__ downstream, o

              downstream << o.normal_datetime.year.to_s  # etc

              NIL_
            end

          end  # >>

          DAYS_PER_BLOCK = 365  # :+#what-about-leap-year

          INTERNAL_UNIT = :year
    end
  end
end
