module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Events_

        class << self

          def potential_event_for_log e, t, full_POI
            For_Log__.new( e, t, full_POI ).route
          end

          def potential_event_for_ls_files e, t, full_POI
            For_Ls_Files___.new( e, t, full_POI ).route
          end
        end  # >>

        def initialize e, t, full_POI
          @d = t.value.exitstatus
          @e = e
          @full_POI = full_POI
        end

        class For_Ls_Files___ < self

          def route

            if @d.zero?
              __when_ES_zero
            else
              self._WHEN_ES_NONZERO
            end
          end

          def __when_ES_zero

            @s = @e.gets
            if @s.nil?
              [[ :error, :directory_is_not_tracked ], -> do
                Directory_is_not_tracked___.new_with(
                  :path, @full_POI,
                  :exitstatus, @d )
              end ]
            else
              self._WHEN_ES_ZERO_AND_SOME_ERRPUT
            end
          end

          Directory_is_not_tracked___ = Common_::Event.prototype_with(

              :directory_is_not_tracked,
              :path, nil,
              :exitstatus, nil,
              :ok, false ) do | y, o |

            y << "directory is not tracked - #{ pth o.path }"
          end
        end

        class For_Log__ < self
          def route
            self._FUN
          end
        end
      end
    end
  end
end
