module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    module Units_::Day

          class << self

        def nearest_previous_block_begin_datetime_ dt

              _d = particular_offset_within_annual_cycle_of_datetime_ dt
              _normal_via_day_offset_and_datetime _d, dt
        end

        def next_block_begin_datetime_after_ dt

              d = particular_offset_within_annual_cycle_of_datetime_ dt

              if 364 == d
                self._YES
                dt.class.new dt.year + 1, 1, 1, 0, 0, 0, dt.zone
              else

                _normal_via_day_offset_and_datetime d + 1, dt
              end
        end

            def _normal_via_day_offset_and_datetime d, dt

              dt.class.new( dt.year, 1, 1, 0, 0, 0, dt.zone ) + d
            end

            def particular_offset_within_annual_cycle_of_datetime_ dt

              dt.yday - 1
            end

          end  # >>
    end
  end
end
