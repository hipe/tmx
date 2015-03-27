
module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      class Actors_::Scale_time

        module Time_Unit_Adapters::Quarter

          extend Common_Time_Unit_Adapter_Module_Methods_

          class << self

            def nearest_previous_bucket_begin_datetime_ dt

              _d = particular_offset_within_annual_cycle_of_datetime_ dt

              _month = 1 + _d * MONTHS_PER_UNIT

              dt.class.new dt.year, _month, 1, 0, 0, 0, dt.zone
            end


            def next_bucket_begin_datetime_after_ dt

              if 7 < dt.month

                dt.class.new dt.year + 1, 1, 1, 0, 0, 0, dt.zone
              else

                _d = particular_offset_within_annual_cycle_of_datetime_ dt

                _m = ( _d + 1 ) * MONTHS_PER_UNIT + 1

                dt.class.new dt.year, _m, 1, 0, 0, 0, dt.zone
              end
            end

            def particular_offset_within_annual_cycle_of_datetime_ dt

              ( dt.month - 1 ) / MONTHS_PER_UNIT

            end
          end  # >>

          MONTHS_PER_UNIT = 3

          UNITS_PER_YEAR = 4

        end
      end
    end
  end
end

