module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      class Actors_::Scale_time

        module Time_Unit_Adapters::Day

          extend Common_Time_Unit_Adapter_Module_Methods_

          class << self

            def nearest_previous_bucket_begin_datetime_ dt

              _normal_via_day_offset_and_datetime(
                particular_offset_within_annual_cycle_of_datetime_( dt ),
                dt )
            end

            def next_bucket_begin_datetime_after_ dt

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
  end
end

