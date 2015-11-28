module Skylab::System::TestSupport

  module IO::Line_Scanner

    class << self
      def [] tcm
        tcm.extend Module_Methods__
        tcm.include Instance__Methods__
      end
    end  # >>

    # <-

  module Module_Methods__

    def with path_s, & o_p
      define_method :pathname do
        @pathname ||= resolve_some_pathname path_s, o_p
      end
    end
  end

  module Instance__Methods__

    def subject_via_pathname pn, d=nil
      Home_.services.filesystem.line_stream_via_path pn.to_path, d
    end

    def subject_via_filehandle fh, d
      Home_::IO.line_stream fh, d
    end

    def resolve_some_pathname path_s, o_p
      td = resolve_some_tmpdir
      pn = td.join path_s
      if ! pn.exist?  # DANGER ZONE
        fh = pn.open ::File::WRONLY | ::File::CREAT | ::File::TRUNC
        o_p[ fh ]
        fh.close
      end
      pn
    end

    def resolve_some_tmpdir
      Resolve_some_tmpdir__[ do_debug && debug_IO ]
    end

    Resolve_some_tmpdir__ = -> do
      p = -> io do
        x_a = [ :max_mkdirs, 3, :path, TS_.tmpdir_path_ ]
        if io
          x_a.push :be_verbose, true, :infostream, io
        end
        td = TestSupport_.tmpdir.new_via_iambic x_a
        td.exist? or td.prepare
        p = -> _ { td }
        td
      end
      -> io { p[ io ] }
    end.call
  end

# ->
  end
end
