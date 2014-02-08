require_relative '../test-support'

module Skylab::Basic::TestSupport::List::Scanner::For

  ::Skylab::Basic::TestSupport::List::Scanner[ TS__ = self ]

  include CONSTANTS

  Basic = Basic ; TestSupport = TestSupport

  set_tmpdir_pathname do
    _pn = Basic::Lib_::Tmpdir_pathname[]
    _pn.join 'skylab-basic'
  end

  extend TestSupport::Quickie


  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end

    attr_reader :do_debug

    def debug_IO
      Basic::Lib_::Some_stderr_IO[]
    end
  end
end
