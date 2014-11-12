module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Write_any_changed_file

      Callback_::Actor.call self, :properties,
        :edit_session,
        :work_dir_path,
        :is_dry_run,
        :on_event_selectively

      BS_::Lib_::Event_lib[].sender self

      def execute
        ok = write_temp_file
        ok && via_tmpfile_pn
        @result
      end

      def write_temp_file
        @scan = @edit_session.to_line_scan
        line = @scan.gets
        if line
          via_scan_write_lines line
        else
          @result = @on_event_selectively.call :error do
            build_not_OK_event_with :file_was_empty, :path, @edit_session.path
          end
          UNABLE_
        end
      end

      def via_scan_write_lines line
        tmpfile_pn = build_tmpfile_pathname
        @tmpfile = tmpfile_pn.to_path
        io = tmpfile_pn.open WRITE_MODE_
        bytes = 0
        begin
          bytes += io.write line
          line = @scan.gets
        end while line
        io.close
        @scan = nil
        @wrote_bytes = bytes
        PROCEDE_
      end

      def build_tmpfile_pathname
        ::Pathname.new "#{ @work_dir_path }/tmpfile.txt"
      end

      def via_tmpfile_pn
        # we could compare the byte count first with stat, but why?
        is_same = BS_::Lib_::File_utils[].cmp @edit_session.path, @tmpfile
        if is_same
          when_no_change
        else
          flush
        end
      end

      def when_no_change
        @result = @on_event_selectively.call :info do
          build_neutral_event_with :no_change, :path, @edit_session.path
        end
        nil
      end

      def flush
        _fuc = BS_::Lib_::System[].filesystem.file_utils_controller.new -> msg do
          @result = @on_event_selectively.call :info do
            Changed_[ @edit_session.path, @is_dry_run ]
          end
        end
        _fuc.mv @tmpfile, @edit_session.path, noop: @is_dry_run  # result is nil
        nil
      end

      Changed_ = BS_::Lib_::Event_lib[].prototype_with :changed_file,
        :path, nil, :is_dry_run, nil, :ok, true

    end
  end
end
