module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      class Actors_::Scale_time

        class Scale_Adapters_::Quarterly < Scale_time_::Common_Scale_Adapter_

          class << self

            def next
              :Semi_Annual
            end
          end  # >>

          DAYS_PER_BUCKET = Rational 365 / 4  # :+#what-about-leap-year

          INTERNAL_UNIT = :quarter

          def within__4__ sumzn

            _d = Time_Unit_Adapters[ INTERNAL_UNIT ].
              particular_offset_within_annual_cycle_of_datetime_(
                sumzn.subject.normal_datetime )

            _s = case _d

            when 1 ; SECOND_Q_IN_FOUR___
            when 2 ; THIRD_Q_IN_FOUR___
            when 3 ; FOURTH_Q_IN_FOUR___
            when 0 ; self.FIRST_Q_IN_FOUR____
            else   ; nil
            end

            sumzn.downstream << _s

            NIL_
          end

          SECOND_Q_IN_FOUR___ = '  Q2'
          THIRD_Q_IN_FOUR___ = '  Q3'
          FOURTH_Q_IN_FOUR___ = '  Q4'
        end
      end
    end
  end
end
