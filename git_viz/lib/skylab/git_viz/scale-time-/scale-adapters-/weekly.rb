module Skylab::GitViz

  class ScaleTime_

    class Scale_Adapters_::Weekly < Here_::CommonScaleAdapter_

          class << self

            def next
              :Monthly
            end
          end  # >>

          DAYS_PER_BUCKET = 7

          INTERNAL_UNIT = :week

          def within__4__ sumzn

            sumzn.downstream << ( FORMAT___ %
              ((( sumzn.subject.normal_datetime.yday - 1 ) / 7 ) + 1 ) )

            NIL_
          end

          FORMAT___ = 'wk%2d'
    end
  end
end
