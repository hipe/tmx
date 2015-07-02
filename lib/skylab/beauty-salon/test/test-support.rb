require_relative '../core'
require 'skylab/test-support/core'

module Skylab::BeautySalon::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  TestLib_ = ::Module.new

  module Constants
    Home_ = ::Skylab::BeautySalon
    Callback_ = Home_::Callback_
    TestLib_ = TestLib_
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  TestSupport_ = TestSupport_

  Home_ = Home_

  module InstanceMethods

    def existent_empty_tmpdir_path
      td = existent_tmpdir.tmpdir_via_join 'started-out-empty'
      if ! do_debug != ! td.be_verbose
        td = td.with :be_verbose, do_debug, :debug_IO, debug_IO
      end
      td.clear.to_path
    end

    def existent_tmpdir_path
      existent_tmpdir.to_path
    end

    def existent_tmpdir
      Memoized_tmpdir__[] || Memoize_tmpdir__[ do_debug, debug_IO ]
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

      _pn = Home_.lib_.system.defaults.dev_tmpdir_pathname.join 'bertie-serern'

      _TMPDIR = Home_.lib_.system.filesystem.tmpdir :path, _pn.to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO,
        :max_mkdirs, 1

      _TMPDIR.exist? or _TMPDIR.prepare
      _TMPDIR

    end
  end.call

  module TestLib_

    Expect_event = -> test_context_cls do
      Constants::Callback_.test_support::Expect_Event[ test_context_cls ]
    end

    Expect_interactive = -> x do
      Home_.lib_.brazen.test_support.expect_interactive x
    end

  end
end
