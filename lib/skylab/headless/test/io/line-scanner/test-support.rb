require_relative '../test-support'

module Skylab::Headless::TestSupport::IO::Line_Scanner

  ::Skylab::Headless::TestSupport::IO[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Headless_ = Headless_

  TestSupport_ = TestSupport_

  module ModuleMethods

    def with path_s, & o_p
      define_method :pathname do
        @pathname ||= resolve_some_pathname path_s, o_p
      end
    end
  end

  module InstanceMethods

    def subject_via_pathname pn, d=nil
      Headless_.system.filesystem.line_scanner_via_pathname pn, d
    end

    def subject_via_filehandle fh, d
      Headless_::IO.line_scanner fh, d
    end

    def resolve_some_pathname path_s, o_p
      td = resolve_some_tmpdir
      pn = td.join path_s
      if ! pn.exist?  # DANGER ZONE
        fh = pn.open 'w'
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
        x_a = [ :max_mkdirs, 3, :path, TS_.tmpdir_pathname ]
        if io
          x_a.push :be_verbose, true, :infostream, io
        end
        td = TestSupport_.tmpdir.build_via_iambic x_a
        td.exist? or td.prepare
        p = -> _ { td }
        td
      end
      -> io { p[ io ] }
    end.call
  end
end
