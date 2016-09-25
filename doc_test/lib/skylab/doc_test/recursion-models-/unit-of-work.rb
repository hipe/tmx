module Skylab::DocTest

  class RecursionModels_::UnitOfWork

    class << self
      alias_method :prototype, :new
      undef_method :new
    end  # >>

    def initialize do_list, vcs_rdr, fs, &p
      if do_list
        @_express = :__express_when_listing
      else
        __init_prototype_for_execution p, vcs_rdr, fs
      end
      freeze
    end

    def new details, path
      dup.init_copy details, path
    end

    def init_copy details, path
      @asset_path = path
      @_details = details
      self
    end

    def express_into_under y, expag
      send @_express, y, expag
    end

    # --

    def __express_when_listing y, expag

      tp = test_path
      ap = asset_path
      if tp && ap  # don't break our would-be CSV columns with blanks
        _create_or_update = CREATE_OR_UPDATE___.fetch test_path_is_real
        y << "#{ _create_or_update } #{ tp } #{ ap }"
      else
        y << "error:missing-path"
      end
      y
    end

    CREATE_OR_UPDATE___ = {
      true => 'would-update',
      false => 'would-create',
    }

    # --

    def __init_prototype_for_execution p, vcs_rdr, fs

      @counts = Counts___.new 0, 0, 0, 0  # strange to put this in the prototype..

      @_express = :__express_when_executing

      @_filesystem = fs

      @__the_synchronize_operation_prototype =
        Home_::Operations_::Synchronize.prototype_for_recurse__ p, :quickie  # #todo

      @__VCS_reader = vcs_rdr

      @_on_event_selectively = p
      NIL
    end

    Counts___ = ::Struct.new :created, :lines, :skipped, :updated

    def __express_when_executing y, _expag

      @_test_file_probably_existed = test_path_is_real

      @_test_path = test_path

      st = __output_test_file_line_stream
      if st
        if @_test_file_probably_existed
          __update_existing_test_file st
        else
          __create_new_test_file st
        end
      else
        # #todo - not covered - (corresponds to other not covered points)
      end

      y  # only because of silly compatibility with "express result" near [#ze-025]
    end

    def __update_existing_test_file st

      path = @_test_path
      o = @__VCS_reader.status_via_path path
      if o.is_versioned
        if o.has_unversioned_changes
          ok = false
          reason_s = "has changes"
        else
          ok = true
        end
      else
        ok = false
        reason_s = "is not versioned"
      end

      if ok
        __DO_CLOBBER_EXISTING_TEST_FILE__ st
      else
        @_on_event_selectively.call :info, :expression, :file_write_summary, :skipped do |y|
          y << "skipping because #{ reason_s }: #{ pth path }"
        end
        @counts.skipped += 1
      end
      NIL
    end

    def __DO_CLOBBER_EXISTING_TEST_FILE__ st  # be careful - no tmpfiles, no undo

      path = @_test_path
      fh = @_filesystem.open path, ::File::TRUNC | ::File::WRONLY
      lines, bytes = _write fh, st
      fh.close

      @_on_event_selectively.call :info, :expression, :file_write_summary, :updated do |y|
        y << "updated #{ pth path } (#{ lines } lines, #{ bytes } bytes)"
      end
      @counts.lines += lines
      @counts.updated += 1
      NIL
    end

    def __create_new_test_file st

      path = @_test_path
      fh = @_filesystem.open path, ::File::CREAT | ::File::EXCL | ::File::WRONLY
      lines, bytes = _write fh, st
      fh.close

      @_on_event_selectively.call :info, :expression, :file_write_summary, :created do |y|
        y << "created #{ pth path } (#{ lines } lines, #{ bytes } bytes)"
      end
      @counts.lines += lines
      @counts.created += 1
      NIL
    end

    def _write fh, st
      bytes = 0 ; num_lines = 0
      begin
        line = st.gets
        line || break
        num_lines += 1
        bytes += fh.write( line )
        redo
      end while above
      [ num_lines, bytes ]
    end

    def __output_test_file_line_stream

      _asset_line_st = @_filesystem.open asset_path, ::File::RDONLY

      if @_test_file_probably_existed

        test_line_st = @_filesystem.open @_test_path, ::File::RDONLY
        localized_test_path = @_details.localize_test_path @_test_path
      end

      o = @__the_synchronize_operation_prototype.dup
      o.asset_line_stream = _asset_line_st
      o.original_test_line_stream =  test_line_st
      o.original_test_path = localized_test_path
      _ = o.to_line_stream
      _  # #todo
    end

    # --

    def test_path_is_real
      @_details.is_real
    end

    def test_path
      @_details.to_path
    end

    attr_reader(
      :counts,
      :asset_path,
    )
  end
end
