require_relative '../core'


module Skylab::TestSupport::TestSupport

  TS_TS = self

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell  # temporary b.c it isn't in [fa]
    TestSupport = ::Skylab::TestSupport
      Lib_ = TestSupport::Lib_
    TS_TS = TS_TS
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end
  end

  module TestLib_
    Headless__ = ::Skylab::TestSupport::Lib_::Headless__
    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end
  end
end
