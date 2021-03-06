module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    module Units_::Hour

          class << self

        def nearest_previous_block_begin_datetime_ dt

              _normal_via_hour_and_datetime dt.hour, dt
        end

        def next_block_begin_datetime_after_ dt

              if 23 == dt.hour

                _reference = dt.class.new dt.year, dt.month, dt.day, 0, 0, 0, dt.zone
                _reference + 1
              else

                _normal_via_hour_and_datetime dt.hour + 1, dt
              end
        end

            def _normal_via_hour_and_datetime d, dt

              dt.class.new dt.year, dt.month, dt.day, d, 0, 0, dt.zone
            end

            def particular_offset_within_daily_cycle_of_datetime_ dt
              self._WHAT
            end

          end  # >>
    end
  end
end
