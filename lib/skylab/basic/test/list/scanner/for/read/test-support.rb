require_relative '../test-support'

module Skylab::Basic::TestSupport::List::Scanner::For::Read

  ::Skylab::Basic::TestSupport::List::Scanner::For[ TS__ = self ]

  include CONSTANTS

  TestSupport = TestSupport

  extend TestSupport::Quickie

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
        h = { path: TS__.tmpdir_pathname }
        if io
          h[ :verbose ] = true
          h[ :infostream ] = io
        end
        td = TestSupport::Tmpdir.new h
        td.exist? or td.prepare
        p = -> _ { td } ; td
      end
      -> io { p[ io ] }
    end.call
  end
end
