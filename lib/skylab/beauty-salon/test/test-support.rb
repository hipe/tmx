require_relative '../core'
require 'skylab/test-support/core'

module Skylab::BeautySalon::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  TestLib_ = ::Module.new

  module Constants
    BS_ = ::Skylab::BeautySalon
    Callback_ = BS_::Callback_
    TestLib_ = TestLib_
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  TestSupport_ = TestSupport_

  BS_ = BS_

  module InstanceMethods

    def existent_tmpdir_path
      pn = Memoized_tmpdir__[]
      pn ||= Memoize_tmpdir__[ do_debug, debug_IO ]
      pn.to_path
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  -> do
    _TMPDIR = nil
    Memoized_tmpdir__ = -> do
      _TMPDIR
    end

    Memoize_tmpdir__ = -> do_debug, debug_IO do

      _pn = BS_::Lib_::System[].defaults.dev_tmpdir_pathname.join 'bertie-serern'

      _TMPDIR = BS_::Lib_::System[].filesystem.tmpdir :path, _pn.to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO,
        :max_mkdirs, 1

      _TMPDIR.exist? or _TMPDIR.prepare
      _TMPDIR

    end
  end.call

  module TestLib_

    Expect_event = -> test_context_mod do
      BS_::Lib_::Brazen[].test_support::Expect_Event[ test_context_mod ]
    end

  end
end
