module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    module Units_::Month

          class << self

        def nearest_previous_block_begin_datetime_ dt

              _normal_via_month_and_datetime dt.month, dt
        end

        def next_block_begin_datetime_after_ dt

              if 12 == dt.month

                dt.class.new dt.year + 1, 1, 1, 0, 0, 0, dt.zone

              else

                _normal_via_month_and_datetime dt.month + 1, dt
              end
        end

            def _normal_via_month_and_datetime d, dt

              dt.class.new dt.year, d, 1, 0, 0, 0, dt.zone
            end

            def particular_offset_within_annual_cycle_of_datetime_ dt
              dt.month - 1
            end

          end  # >>
    end
  end
end
