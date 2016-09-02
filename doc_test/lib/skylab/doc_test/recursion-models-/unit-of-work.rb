module Skylab::DocTest

  class RecursionModels_::UnitOfWork

    class << self
      alias_method :prototype, :new
      undef_method :new
    end  # >>

    def initialize do_list, fs, &p
      if do_list
        @_express = :__express_when_listing
      else
        __init_prototype_for_execution p, fs
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

    def __init_prototype_for_execution p, fs

      @_express = :__express_when_executing

      @_filesystem = fs

      @__the_synchronize_operation_prototype =
        Home_::Operations_::Synchronize.prototype_for_recurse__ p, :quickie  # #todo

      @_on_event_selectively = p
      NIL
    end

    def __express_when_executing y, _expag

      @_test_file_probably_existed = test_path_is_real
      @_test_path = test_path

      st = __output_test_file_line_stream

      if @_test_file_probably_existed
        self._UH_OH
      else
        __create_new_test_file st
      end

      y  # only because of silly compatibility with "express result" near [#ze-025]
    end

    def __create_new_test_file st

      path = @_test_path
      fh = @_filesystem.open path, ::File::CREAT | ::File::EXCL | ::File::WRONLY
      # #flock #todo
      lines, bytes = _write fh, st
      fh.close

      @_on_event_selectively.call :info, :expression, :file_write_summary, :created do |y|
        y << "created #{ pth path } (#{ lines } lines, #{ bytes } bytes)"
      end

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

      _any_test_line_st = if @_test_file_probably_existed

        @_filesystem.open @_test_path, ::File::RDONLY
      end

      o = @__the_synchronize_operation_prototype.dup
      o.asset_line_stream = _asset_line_st
      o.original_test_line_stream = _any_test_line_st
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
      :asset_path,
    )
  end
end
