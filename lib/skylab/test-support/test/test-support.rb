require_relative '../core'


module Skylab::TestSupport::TestSupport

  TS_TS = self

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell  # temporary b.c it isn't in [fa]
    TS_TS = TS_TS
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end
  end

  SYSTEM_ = TestSupport::Headless::System.defaults

end
