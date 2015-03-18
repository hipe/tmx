module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Actors_::Build

        Callback_::Actor.call self, :properties, :path, :repo

        def execute

          @build_trail = Actors_::Build_trail.new( @repo, & @on_event_selectively )

          @list_of_trails = []

          ok = __normalize_path_appearance
          ok &&= __normalize_path_on_filesystem
          ok &&= __via_path_resolve_line_stream
          ok &&= __for_each_path_etc
          ok && __flush
        end

        def __normalize_path_appearance

          _n11n = GitViz_.lib_.basic::Pathname.normalization

          _ = _n11n.new_with :relative, :downward_only, :no_single_dots

          arg = _.normalize_value @path, & @on_event_selectively

          arg and begin

            @path = arg.value_x  # probably same object
            ACHIEVED_
          end
        end

        def __normalize_path_on_filesystem

          _pn_of_interest = @repo.pn_.join @path

          fs = GitViz_.lib_.system.filesystem

          fs.normalization.upstream_IO(
            :pathname, _pn_of_interest,
            :only_apply_expectation_that_path_is_ftype_of,
              fs.class::DIRECTORY_FTYPE,
            & @on_event_selectively )
        end

        def __via_path_resolve_line_stream

          # assume that last time we check, path is a relpath of interest
          # that is a directory and is or is not tracked

          full_POI = ::File.join @repo.path, @path

          _i, @upstream_lines, e, t = @repo.repo_popen_3_(
            * LS_FILES_BASE_CMD_, chdir: full_POI )  # :[#012]:#the-git-ls-files-command

          # watch these assumptions:

          line = @upstream_lines.gets
          if line
            @line = line
            ACHIEVED_
          else
            i_a, ev_p = Bundle_::Events_.potential_event_for_ls_files(
              e, t, full_POI )
            @on_event_selectively.call( * i_a, & ev_p )
          end
        end

        def __for_each_path_etc
          ok = true
          line = @line
          begin
            line.chomp!
            ok = __process_path line
            ok or break
            line = @upstream_lines.gets
            line and redo
            break
          end while nil
          ok
        end

        def __process_path path

          trail = @build_trail[ path ]
          if trail
            @list_of_trails.push trail
            ACHIEVED_
          else
            trail
          end
        end

        def __flush
          o = @build_trail
          bx = Callback_::Box.allocate
          bx.instance_exec do
            @a = o.ci_sha_a
            @h = o.ci_cache
          end
          Bundle_.new( @list_of_trails, bx )
        end
      end
    end
  end
end
