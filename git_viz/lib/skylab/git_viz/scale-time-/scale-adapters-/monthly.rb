module Skylab::GitViz

  class ScaleTime_

    class Scale_Adapters_::Monthly < Here_::CommonScaleAdapter_

          class << self

            def next
              :Quarterly
            end

            def within_ sumzn

              sumzn.downstream << string_within_( sumzn )

              NIL_
            end

            def string_within_ sumzn

              send :"__string_within__#{ sumzn.width }__", sumzn
            end

            def __string_within__4__ sumzn

              sumzn.subject.normal_datetime.strftime FORMAT_FOR_WIDTH_4___
            end
          end  # >>

          DAYS_PER_BUCKET = 28  # :+#bids-are-lossy-pessimistic-estimates

          FORMAT_FOR_WIDTH_4___ = ' %b'

          INTERNAL_UNIT = :month

          def within__4__ sumzn

            self.class.within_ sumzn

            NIL_
          end
    end
  end
end
