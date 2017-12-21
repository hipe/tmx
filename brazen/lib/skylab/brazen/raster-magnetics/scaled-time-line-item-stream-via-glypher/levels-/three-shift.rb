module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    class Levels_::Three_Shift < Here_::CommonLevel_

          class << self

            def next
              :Daily
            end

            def time_unit_adapter_
              self
            end

            def nearest_previous_block_begin_datetime_ dt

              _normal_via_particular_offset_and_datetime(
                particular_offset_within_daily_cycle_of_datetime_( dt ), dt )
            end

            def next_block_begin_datetime_after_ dt

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

          DAYS_PER_BLOCK = Rational 1, 3

          def initialize( * )
            super
            @p = method :initial_state_
          end

          define_method :within, STATE_DRIVEN_WITHIN_

          def particular_ sumzn  # assume has content

            Levels_::Hourly.within_ sumzn

            NIL_
          end
    end
  end
end
