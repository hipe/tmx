module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      class Actors_::Scale_time

        class Scale_Adapters_::Three_Shift < Scale_time_::Common_Scale_Adapter_

          class << self

            def next
              :Daily
            end

            def _time_unit_adapter_
              self
            end

            def nearest_previous_bucket_begin_datetime_ dt

              _normal_via_particular_offset_and_datetime(
                particular_offset_within_daily_cycle_of_datetime_( dt ), dt )
            end

            def next_bucket_begin_datetime_after_ dt

              d = particular_offset_within_daily_cycle_of_datetime_ dt

              if 2 == d

                dt.class.new( dt.year, dt.month, dt.day ) + 1
              else

                _normal_via_particular_offset_and_datetime d + 1, dt
              end
            end

            def particular_offset_within_daily_cycle_of_datetime_ dt

              dt.hour / 8
            end

            def _normal_via_particular_offset_and_datetime d, dt

              dt.class.new dt.year, dt.month, dt.day, 8 * d, 0, 0, dt.zone
            end

          end  # >>

          DAYS_PER_BUCKET = Rational 1, 3

          def initialize( * )
            super
            @p = method :initial_state_
          end

          define_method :within, STATE_DRIVEN_WITHIN_

          def particular_ sumzn  # assume has content

            Scale_Adapters_::Hourly.within_ sumzn

            NIL_
          end
        end
      end
    end
  end
end
