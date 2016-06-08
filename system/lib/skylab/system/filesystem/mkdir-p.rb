module Skylab::System

  module Filesystem

    class Mkdir_p < Common_::Actor::Dyadic  # :[#026].

      # we do this on our own instead of using the FileUtils method because
      # A) we don't like FileUtils's way of "emitting" "events" and B) this
      # one is a derivative of a filesystem "reduced instruction set" making
      # it useful on top of a mocked filesystem.
      #
      # additionally, as an experiment we weirdly lock all involved
      # directories while we are doing the operation, to play with the idea
      # of atomicity. (we must unlock them before this actor returns,
      # however, lest it make itself fail on subsequent invocations on a
      # sub-directory of the same directory (encountered))

      def initialize path, fs, & oes_p

        @filesystem = fs
        @path = path
        @on_event_selectively = oes_p
      end

      def execute

        __init_stack
        __execute_stack
      end

      def __init_stack

        path = remove_instance_variable :@path

        scn = Home_.lib_.basic::String.reverse_scanner path, FILE_SEPARATOR_BYTE
        s = scn.gets

        if s.length.zero?  # then path had a trailing separator. ignorable
          tail_width = 1
          s = scn.gets
        else
          tail_width = 0
        end

        s or self._COVER_ME_no_path
        stack = [ s ]
        begin
          s_ = scn.gets
          if s_
            if s_.length.zero?
              self._SANITY_root_doesnt_exist?
            end
            tail_width += 1 + s.length  # assume file separator is length 1
            s = s_
            try_path = path[ 0 ... - tail_width ]

            if @filesystem.exist? try_path
              break
            else
              stack.push s
              redo
            end
          else
            raise ::ArgumentError, __say_relative( path )
          end
        end while nil

        @_existant_directory_filehandle = _lock_directory try_path
        @_stack = stack
        NIL_
      end

      def __say_relative path
        "realtive path - #{ path }"
      end

      def __execute_stack

        dh = remove_instance_variable :@_existant_directory_filehandle
        fs = @filesystem
        stack = remove_instance_variable :@_stack

        exists = dh.path

        _oes_p = remove_instance_variable :@on_event_selectively

        _oes_p.call :info, :mkdir_p do
          __build_event stack.dup.freeze, exists
        end

        entry = stack.pop
        locked = [ dh ]

        begin

          mkdir = ::File.join exists, entry

          d = fs.mkdir mkdir
          d.zero? or self._COVER_ME_mkdir_returned_nonzero_exitstatus

          locked.push _lock_directory mkdir

          entry = stack.pop
          if entry
            exists = mkdir
            redo
          end
          break
        end while nil

        locked.each do | dh_ |
          d = dh_.flock ::File::LOCK_UN
          d.zero? or self._COVER_ME_failed_to_unlock
        end

        ACHIEVED_
      end

      def _lock_directory path

        # assume `path` existed a moment ago. we weirdly "open" the
        # directory and put an exclusive lock on it. we like the idea that
        # this prevents the directory from getting removed by another
        # process while we are doing this, but things are not likely that
        # simple.

        dh = @filesystem.open path, ::File::RDONLY
        d = dh.flock ::File::LOCK_EX | ::File::LOCK_NB
        if d
          d.zero? or self._COVER_ME_nonnzero_flock_exitstatus
          dh
        else
          self._COVER_ME_failed_to_lock
        end
      end

      def __build_event stack, path

        Common_::Event.inline_neutral_with( :mkdir_p,
          :stack, stack,
          :path, path,

        ) do | y, o |
          y << "making #{ o.stack * ::File::SEPARATOR } #{
            }under #{ pth o.path }"
        end
      end
    end
  end
end
