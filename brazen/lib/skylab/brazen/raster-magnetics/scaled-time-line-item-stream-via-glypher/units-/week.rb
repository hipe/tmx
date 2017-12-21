module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    module Units_::Week

          class << self

        def nearest_previous_block_begin_datetime_ dt

              _wk_idx = particular_offset_within_annual_cycle_of_datetime_ dt

              _normal_via_week_index_and_datetime _wk_idx, dt
        end

        def next_block_begin_datetime_after_ dt

              d = particular_offset_within_annual_cycle_of_datetime_ dt

              if 51 == d

                dt.class.new dt.year + 1, 1, 1, 0, 0, 0, dt.zone
              else

                _normal_via_week_index_and_datetime d + 1, dt
              end
        end

            def _normal_via_week_index_and_datetime wk_idx, dt

              _year_dt = dt.class.new dt.year, 1, 1, 0, 0, 0, dt.zone

              _year_dt + ( wk_idx * 7 )
            end

            def particular_offset_within_annual_cycle_of_datetime_ dt

              ( dt.yday - 1 ) / 7
            end

          end  # >>
    end
  end
end
