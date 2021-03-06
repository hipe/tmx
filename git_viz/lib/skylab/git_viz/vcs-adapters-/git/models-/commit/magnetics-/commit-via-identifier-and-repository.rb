module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Commit

      class Magnetics_::Commit_via_Identifier_and_Repository < Common_::Dyadic

        def initialize s, o, & p
          @id_s = s
          @listener = p
          @repo = o
        end

        def execute

          _, @o, @e, @t = @repo.repo_popen_3_( * BASE_CMD_, @id_s, DOUBLE_DASH___ )

            # [#009]:#storypoint-15

          if GIT_GENERAL_ERROR_ == @t.value.exitstatus

            __when_general_error
          else

            __assume_found
          end
        end

        DOUBLE_DASH___ = '--'

        def __when_general_error

          s = @e.gets
          i_a, ev_p = Commit_::Events_.any_potential_event_for s, @t
          if i_a
            @listener[ * i_a, & ev_p ]
            UNABLE_
          else
            self._DO_ME
          end
        end

        def __assume_found

          s = @e.gets
          s and raise s

          @t.value.exitstatus.nonzero? and self._DO_ME

          ok = false
          o = @o
          x = Commit_.new do
            ok = Commit_::Magnetics_::Commit_via_LineStream[ self, o ]
            ok && freeze
          end
          ok && x
        end
      end
    end
  end
end
