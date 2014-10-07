require_relative '../test-support'

module Skylab::Basic::TestSupport::List::Scanner::For

  ::Skylab::Basic::TestSupport::List::Scanner[ self ]

  include CONSTANTS

  Basic_ = Basic_ ; TestSupport_ = TestSupport_

  set_tmpdir_pathname do
    _pn = Basic_::Lib_::Tmpdir_pathname[]
    _pn.join 'skylab-basic'
  end

  extend TestSupport_::Quickie


  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end

    attr_reader :do_debug

    def debug_IO
      Basic_::Lib_::Some_stderr_IO[]
    end
  end
end
