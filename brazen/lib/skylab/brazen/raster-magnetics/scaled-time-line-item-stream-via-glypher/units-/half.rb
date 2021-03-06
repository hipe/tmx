module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    module Units_::Half

          class << self

        def nearest_previous_block_begin_datetime_ dt

              # because there is variation in how long the months
              # are, we cannot do this with simple day arithmetic.

              if 6 < dt.month
                dt.class.new dt.year, 7, 1, 0, 0, 0, dt.zone
              else
                dt.class.new dt.year, 1, 1, 0, 0, 0, dt.zone
              end
        end

        def next_block_begin_datetime_after_ dt

              if 6 < dt.month
                dt.class.new dt.year + 1, 1, 1, 0, 0, 0, dt.zone
              else
                dt.class.new dt.year, 7, 1, 0, 0, 0, dt.zone
              end
        end

            def particular_offset_within_annual_cycle_of_datetime_ dt

              # ditto

              if 6 < dt.month
                1
              else
                0
              end
            end
          end  # >>

          UNITS_PER_YEAR = 2
    end
  end
end
