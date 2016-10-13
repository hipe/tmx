module Skylab::GitViz

  class ScaleTime_

    module TimeUnitAdapters_::Year

          extend Common_Time_Unit_Adapter_Module_Methods_

          class << self

            def nearest_previous_bucket_begin_datetime_ dt

              dt.class.new dt.year, 1, 1, 0, 0, 0, dt.zone

            end

            def next_bucket_begin_datetime_after_ dt

              dt.class.new dt.year + 1, 1, 1, 0, 0, 0, dt.zone
            end

            def particular_offset_within_annual_cycle_of_datetime_ dt

              0
            end
          end  # >>
    end
  end
end
