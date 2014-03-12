require_relative '../core'

module Skylab::TestSupport::TestSupport

  TestSupport_ = ::Skylab::TestSupport
  TS_TS = self

  module CONSTANTS
    EMPTY_A_ = TestSupport_::EMPTY_A_
    Lib_ = TestSupport_::Lib_
    TestSupport_ = TestSupport_
    TS_TS = TS_TS
  end

  include CONSTANTS

  TestSupport_::Regret[ self ]

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      @debug_IO ||= TestSupport_::Lib_::Stderr[]
    end
  end

  module TestLib_
    memoize = TestSupport_::Callback_.memoize
    Face_module = -> do
      TestSupport_::Lib_::Face__[]
    end
    Headless__ = ::Skylab::TestSupport::Lib_::Headless__
    System_pathnames_calculate = -> p do
      _pn = Subsystem__[]::PATHNAMES
      _pn.module_exec( & p )  # call it 'calculate' instead and #core-dump
    end
    Subsystem__ = memoize[ -> do
      ::Skylab::Subsystem  # or..
    end ]
    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end
  end
end
