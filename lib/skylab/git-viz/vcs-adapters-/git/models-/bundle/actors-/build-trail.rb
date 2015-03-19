module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Actors_::Build_trail

        def initialize repo, & oes_p
          @ci_sha_a = []
          @ci_cache = {}
          @on_event_selectively = oes_p
          @repo = repo
          s = @repo.relative_path_of_interest

          @normalize_path = if s && s.length.nonzero? && DOT_ != s
            -> x { ::File.join s, x }
          else
            -> x { x }  # IDENTITY_
          end

          freeze
        end

        attr_reader :ci_cache, :ci_sha_a

        def [] path
          dup.__execute path
        end

        protected def __execute path

          path_ = @normalize_path[ path ]

          @trail = []
          _, o, e, t = @repo.repo_popen_3_( * LOG_BASE_CMD_, path_ )
          line = o.gets
          if line

            @normal_received_path = path_
            @o = o

            ok = __via_output line
            ok && @trail
          else
            i_a, ev_p = Bundle_::Events_.potential_event_for_log(
              e, t, ::File.join( @repo.path, @normal_received_path ) )

            @on_event_selectively.call( * i_a,  ev_p )
          end
        end

        def __via_output line

          @curr_path = @normal_received_path
          ok = true
          begin
            line.strip!
            ok = __process_SHA line
            ok or break
            line = @o.gets
            line or break
            redo
          end while nil
          if ok
            @trail.reverse!  # the commits came to use most recent to oldest
          end
          ok
        end

        def __process_SHA sha

          ci = __produce_ci sha

          fc = ci.fetch_filechange_via_end_path @curr_path

          if fc.is_rename
            @curr_path = fc.source_path
          end

          @trail.push Bundle_Filechange___.new( fc, ci.SHA )

          ACHIEVED_
        end

        def __produce_ci sha
          @ci_cache.fetch sha do
            ci = @repo.fetch_commit_via_identifier sha
            @ci_sha_a.push sha
            @ci_cache[ sha ] = ci
            ci
          end
        end
      end

      class Bundle_Filechange___  # :+#stowaway
        def initialize fc, _SHA
          @fc = fc
          @SHA = _SHA
        end
        attr_reader :fc, :SHA
      end
    end
  end
end
