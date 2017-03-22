module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Repository  # see [#016]

      class << self

        def new_via path, system, filesystem, & oes_p

          dir = Find_repository_path___[ path, filesystem, & oes_p ]

          if dir

            new path, dir, system, & oes_p
          else
            dir
          end
        end

        private :new
      end  # >>

      attr_reader(
        :path,
        :relative_path_of_interest,
      )

      def initialize arg_path, project_path, system, & oes_p

        @on_event_selectively = oes_p

        @path = project_path

        _rpoi = if project_path == arg_path
          NIL_
        else

          Magnetics_::Relpath_via_Long_and_Short[ arg_path, project_path ]
        end

        @relative_path_of_interest = _rpoi || DOT_

        @system_conduit = system

        # M-etaHell::F-UN.without_warning { Home_.lib_.grit }  # see [#016]:#as-for-grit
        # @inner = ::Grit::Repo.new absolute_pn.to_path ; nil
      end

      def fetch_commit_via_identifier id_s, & oes_p

        oes_p ||= @on_event_selectively

        Models_::Commit.fetch_via_identifier__ id_s, self, & oes_p
      end

      def repo_popen_3_ * s_a

        s_a.unshift GIT_EXE_

        if ! ::Hash.try_convert( s_a.last )
          s_a.push chdir: @path
        end

        @system_conduit.popen3( * s_a )
      end

      def vendor_program_name  # :+#public-API
        GIT_EXE_
      end

      class Find_repository_path___

        class << self
          def [] path, fs, & oes_p
            new( path, fs, & oes_p ).execute
          end
          private :new
        end  # >>

        def initialize path, fs, & oes_p
          @path = path ; @fs = fs ; @on_event_selectively = oes_p
        end

        def execute

          if @fs.path_looks_absolute @path

            _is_file = @fs.file? @path

            if _is_file
              @_start_path = ::File.dirname @path
            else
              @_start_path = @path
            end

            __money
          else
            raise Home_::ArgumentError, __say
          end
        end

        def __say
          "relative paths are not honored here - #{ @path }"
        end

        def __money

          _FS = Home_.lib_.system_lib::Filesystem

          _FS::Walk.via(
            :start_path, @_start_path,
            :filesystem, @fs,
            :filename, VENDOR_DIR_,
            :max_num_dirs_to_look, -1,
            :ftype, _FS::DIRECTORY_FTYPE,
            & @on_event_selectively )
        end
      end
    end
  end
end
# :+#tombstone: [#008] `Simple_Agent_` was replaced by [cb] actor
