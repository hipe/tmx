module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Actors_::Build_trail

        def initialize stats, repo, & oes_p

          @ci_sha_a = []
          @ci_cache = {}

          s = repo.relative_path_of_interest

          @normalize_path = if s && s.length.nonzero? && DOT_ != s
            -> x { ::File.join s, x }
          else
            -> x { x }  # IDENTITY_
          end

          @on_event_selectively = oes_p
          @repo = repo
          @statistics = stats

          freeze
        end

        attr_reader :ci_cache, :ci_sha_a

        def [] path
          dup.__execute path
        end

        protected def __execute path

          path_ = @normalize_path[ path ]

          @fc_a = []
          _, o, e, t = @repo.repo_popen_3_( * LOG_BASE_CMD_, path_ )
          line = o.gets
          if line

            @normal_received_path = path_
            @o = o

            _ok = __via_output line
            _ok and __flush path
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
            @fc_a.reverse!  # the commits came to use most recent to oldest
          end
          ok
        end

        def __process_SHA sha

          ci = __produce_ci sha

          fc = ci.fetch_filechange_via_end_path @curr_path

          fc.write_statistics @statistics

          if fc.is_rename
            @curr_path = fc.source_path
          end

          @fc_a.push Bundle_Filechange___.new( fc, ci.SHA )

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

        def __flush path

          Trail__.new @fc_a, path
        end
      end

      class Trail__

        def initialize fca, path

          @filechanges = fca
          @path = path
        end

        attr_reader :filechanges, :path

        def to_tree_path  # #hook-out for [st]
          @path
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
