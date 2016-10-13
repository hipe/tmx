module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Magnetics_::Trail_via_Paths_and_Repository

        # (a VERY custom session interface)

        def initialize stats, repo, rsx, & oes_p

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

          @stderr = rsx.stderr

          freeze
        end

        attr_reader :ci_cache, :ci_sha_a

        def [] path
          dup.__execute path
        end

        protected def __execute path

          @stderr.write C___

          path_ = @normalize_path[ path ]

          @fc_a = []
          # $stderr.puts "git #{ [ * LOG_BASE_CMD_ , path_ ].join ' ' }"
          _, o, e, t = @repo.repo_popen_3_( * LOG_BASE_CMD_, path_ )
          line = o.gets
          if line

            @normal_received_path = path_
            @o = o

            _ok = __via_output line
            _ok and __flush path
          else
            i_a, ev_p = Here_::Events_.potential_event_for_log(
              e, t, ::File.join( @repo.path, @normal_received_path ) )

            @on_event_selectively.call( * i_a,  ev_p )
          end
        end

        C___ = 'C'

        def __via_output line

          @curr_path = @normal_received_path
          ok = true
          @found_false_match = false
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

          fc = ci.fetch_filechange_via_end_path @curr_path do end

          if fc
            if @found_false_match
              @found_false_match = false
              @stderr.write 'r)'
            end
            __process_filechange fc, ci
          else

            # case studies for when/why this happens are in [#032] a "false matches"

            if @found_false_match
              @stderr.write 'f'
            else
              @stderr.write '(F'
              @found_false_match = true
            end
            ACHIEVED_
          end
        end

        def __process_filechange fc, ci

          fc.write_statistics @statistics

          if fc.is_rename
            @curr_path = fc.source_path
          end

          @fc_a.push Bundle_Filechange___.new( fc, ci )

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
        def initialize fc, ci
          @ci = ci
          @fc = fc
        end
        attr_reader :ci, :fc
        def SHA
          @ci.SHA
        end
      end
    end
  end
end
