module Skylab::SearchAndReplace

    class Magnetics_::Write_changed_file_via_mutable_file_session

      # resolve a locked, writable filehandle to a tmpfile.
      # line by line, write the new file state to the tmpfile.
      # then IFF there were nonzero bytes written, use the filesystem
      # to copy the tmpfile over to the "real" file location.
      # implement dry run (expressed in the positive: `write_is_enabled`).
      #
      # we use the intermediate tmpfile (for now) for a number of
      # "instinctual" reasons, the main one being that we don't want
      # to corrupt the "real" file in cases of exceptions thrown while
      # producing the new lines.
      #
      # this will definitely be touched by #open [#004] locking/mtime etc.

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      attr_writer(
        :line_stream,
        :path,
        :write_is_enabled,
      )

      def execute
        _ok = __resolve_tmpfile_IO
        _ok && ___via_tmpfile_IO
      end

      def ___via_tmpfile_IO

        tmp_path = @_tmpfile_IO.path
        real_path = @path

        is_dry = ! @write_is_enabled

        _cls = Home_.lib_.system.filesystem.file_utils_controller

        _fuc = _cls.new_via( & method( :___express_unexpected_mv_msg ) )

        @_tmpfile_IO.flush
        d = _fuc.mv tmp_path, real_path, noop: is_dry, verbose: false
        @_tmpfile_IO.close

        if is_dry || d.zero?

          _ev = Home_.lib_.system.filesystem_lib.event( :Wrote ).new_with(
            :bytes, @_bytes,
            :path, real_path,
            :is_dry, is_dry,
          )

          _ev
        else
          UNABLE_
        end
      end

      def ___express_unexpected_mv_msg msg
        self._COVER_ME
        @on_event_selectively.call(
          :error,
          :expression,
          :moving_tmpfile_to_real_file,
        ) do | y |
          y << msg
        end
        NIL_
      end

      def __resolve_tmpfile_IO

        st = @line_stream
        line = st.gets
        if line
          ok = __write_nonzero_lines line, st
          if ok
            if @_bytes.zero?
              _when_no_lines
            else
              ACHIEVED_
            end
          else
            ok
          end
        else
          _when_no_lines
        end
      end

      def _when_no_lines

        _path = @path

        sym = :will_not_write_empty_file

        @on_event_selectively.call :error, sym do
          Callback_::Event.inline_not_OK_with sym, :path, _path
        end
        UNABLE_
      end

      def __write_nonzero_lines line, st

        _path = Tmpfile_path___[]
        io = ::File.open _path, PERM___
        d = io.flock LOCK___
        if d && d.zero?

          io.truncate 0
          bytes = 0

          begin
            _d = io.write line
            bytes += _d
            line = st.gets
          end while line

          @_bytes = bytes
          @_tmpfile_IO = io
          ACHIEVED_
        else
          self._COVER_ME_could_not_lock
        end
      end

      Tmpfile_path___ = Lazy_.call do
        ::File.join Home_.lib_.tmpdir, 'tmpfile.txt'
      end

      LOCK___ = ::File::LOCK_EX | ::File::LOCK_NB
      PERM___ = ::File::CREAT | ::File::WRONLY
    end
  # -
end
# #pending-rename
