require_relative '../test-support'

module Skylab::Basic::TestSupport::List::Scanner::For::Read

  ::Skylab::Basic::TestSupport::List::Scanner::For[ TS__ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  TestSupport_ = TestSupport_

  module ModuleMethods

    def with path_s, & o_p
      define_method :pathname do
        @pathname ||= resolve_some_pathname path_s, o_p
      end
    end
  end

  module InstanceMethods

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
        x_a = [ :max_mkdirs, 2, :path, TS__.tmpdir_pathname ]
        if io
          x_a.push :be_verbose, true, :infostream, io
        end
        td = TestSupport_.tmpdir.via_iambic x_a
        td.exist? or td.prepare
        p = -> _ { td }
        td
      end
      -> io { p[ io ] }
    end.call
  end
end
