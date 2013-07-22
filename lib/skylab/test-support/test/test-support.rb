require_relative '../core'


module Skylab::TestSupport::TestSupport

  TS_TS = self

  module CONSTANTS
    TS_TS = TS_TS
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  module InstanceMethods

    def nearest_indexed_test_support_module
      self.class::TS_HANDLE_
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end
  end

  SYSTEM_ = TestSupport::Headless::System.defaults

end
