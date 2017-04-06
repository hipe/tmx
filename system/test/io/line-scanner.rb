module Skylab::System::TestSupport

  module IO::Line_Scanner

    class << self
      def [] tcm
        tcm.send :define_singleton_method, :with, Definition_for_method_called_with___
        tcm.extend ModuleMethods_
        tcm.include InstanceMethods_for_LineScanner___
      end
    end  # >>

    Definition_for_method_called_with___ = -> path_s, & o_p do
      define_method :pathname do
        @pathname ||= resolve_some_pathname path_s, o_p
      end
    end

    # <-

  module InstanceMethods_for_LineScanner___

    def subject_via_pathname pn, d=nil
      Home_.services.filesystem.line_stream_via_path pn.to_path, d
    end

    def subject_via_filehandle fh, d
      Home_::IO::LineStream_via_PageSize.call_by do |o|
        o.filehandle = fh
        o.page_size = d
      end
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
        td = Home_::Filesystem::Tmpdir.via_iambic x_a
        if ! td.exist?
          td.prepare
        end
        p = -> _ { td }
        td
      end
      -> io { p[ io ] }
    end.call
  end

# ->
  end
end
