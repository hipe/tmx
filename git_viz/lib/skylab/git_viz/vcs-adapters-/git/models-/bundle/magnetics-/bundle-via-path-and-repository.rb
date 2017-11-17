module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Magnetics_::Bundle_via_Path_and_Repository

        Attributes_actor_.call( self,
          :path,
          :repo,
          :rsx,
          :filesystem,
        )

        def initialize & p
          @listener = p
        end

        def execute

          statistics = []

          @build_trail = Magnetics_::Trail_via_Paths_and_Repository.new(
            statistics, @repo, @rsx, & @listener )

          @list_of_trails = []

          @statistics = statistics

          ok = __normalize_path_appearance
          ok &&= __normalize_path_on_filesystem
          ok &&= __via_path_resolve_line_stream
          ok &&= __for_each_path_etc
          ok && __flush
        end

        def __normalize_path_appearance

          _n11n = Home_.lib_.basic::Pathname::Normalization

          _ = _n11n.with :relative, :downward_only  #, :no_single_dots

          arg = _.normalize_value @path, & @listener

          arg and begin

            @path = arg.value  # probably same object
            ACHIEVED_
          end
        end

        def __normalize_path_on_filesystem

          _path = if DOT_ == @path
            @repo.path
          else
           ::File.join @repo.path, @path
          end

          kn = Home_.lib_.system_lib::Filesystem::Normalizations::ExistentDirectory.via(
            :path, _path,
            :filesystem, @filesystem,
            & @listener )

          if kn
            kn.value.to_path  # sanity check that result is a dir object
            ACHIEVED_
          else
            kn
          end
        end

        def __via_path_resolve_line_stream

          # assume that last time we check, path is a relpath of interest
          # that is a directory and is or is not tracked

          full_POI = if DOT_ == @path  # special case?
            @repo.path
          else
            ::File.join @repo.path, @path
          end

          _i, @upstream_lines, e, t = @repo.repo_popen_3_(
            * LS_FILES_BASE_CMD_, chdir: full_POI )  # :[#012]:#the-git-ls-files-command

          # watch these assumptions:

          line = @upstream_lines.gets
          if line
            @line = line
            ACHIEVED_
          else
            i_a, ev_p = Here_::Events_.potential_event_for_ls_files(
              e, t, full_POI )
            @listener.call( * i_a, & ev_p )
            UNABLE_
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
          bx = Common_::Box.allocate
          bx.instance_exec do
            @a = o.ci_sha_a
            @h = o.ci_cache
          end

          @statistics.sort!.freeze

          Here_.new( @statistics, @list_of_trails, bx, @rsx )
        end
      end
    end
  end
end
