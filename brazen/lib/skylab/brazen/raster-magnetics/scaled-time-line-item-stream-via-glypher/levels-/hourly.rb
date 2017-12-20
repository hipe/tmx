module Skylab::GitViz

  class ScaleTime_

    class Scale_Adapters_::Hourly < Here_::CommonScaleAdapter_

          class << self

            def next
              :Three_Shift
            end

            def within_ sumzn

              send :"__within__#{ sumzn.width }__", sumzn
            end

            def __within__4__ sumzn

              sumzn.downstream <<
                sumzn.subject.normal_datetime.strftime( FORMAT_FOR_WIDTH_4___ )
              NIL_
            end
          end  # >>

          DAYS_PER_BUCKET = Rational 1, 24

          FORMAT_FOR_WIDTH_4___ = '%l%p'

          INTERNAL_UNIT = :hour

          def initialize( * )
            super
            @p = method :initial_state_
          end

          define_method :within, STATE_DRIVEN_WITHIN_

          def particular_ sumzn

            self.class.within_ sumzn
          end
    end
  end
end
