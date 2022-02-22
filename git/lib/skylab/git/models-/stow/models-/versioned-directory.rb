module Skylab::Git

  class Models_::Stow

    class Models_::VersionedDirectory

      # model any one directory within a versioned project

      attr_reader(
        :current_relpath,
        :project_path,
      )

      def initialize current_relpath, project_dir, sc, & p

        if DOT_ == current_relpath
          @current_relpath = nil
        else
          current_relpath.length.nonzero? or raise ::ArgumentError
          @current_relpath = current_relpath
        end

        @listener = p
        @project_path = project_dir
        @_sc = sc
      end

      def to_entity_stream

        cmd = COMMAND___

        __maybe_say_command cmd

        _, o, e, w = @_sc.popen3( * cmd, chdir: __chdir_directory )

        # == BEGIN #history-B.1
        unordered = Common_::Stream.by( & o.method(:gets) ).to_a
        ordered = Home_.lib_.system.maybe_sort_filesystem_paths unordered
        o = Common_::Stream.via_nonsparse_array ordered
        # == END

        p = -> do

          s = e.gets
          if s
            @listener.call :error, :expression, :unexpected do | y |
              y << "unexpected errput: #{ s }"
            end
            p = EMPTY_P_
            UNABLE_
          else

            p = -> do
              s = o.gets
              if s
                s.strip!
                s  # ok for now, not to be entity ..
              else
                d = w.value.exitstatus
                if d.zero?
                  p = EMPTY_P_
                  NIL_
                else
                  self._COVER_ME
                end
              end
            end
            p[]
          end
        end

        st = Common_.stream do
          p[]
        end

        if @current_relpath

          path = @current_relpath
          st = st.map_by do | entry_s |
            ::File.join path, entry_s
          end
        end

        st
      end

      COMMAND___ = %w( git ls-files --others --exclude-standard ).freeze

      def __chdir_directory

        if @current_relpath
          ::File.join @project_path, @current_relpath
        else
          @project_path
        end
      end

      def __maybe_say_command cmd

        @listener.call :info, :expression, :command do | y |

          p = Home_.lib_.shellwords.method :shellescape
          y << "command: #{ cmd.map( & p ).join( SPACE_ ) }"
        end
        NIL_
      end
    end
  end
end
# #history-B.1: target Ubuntu not OS X
