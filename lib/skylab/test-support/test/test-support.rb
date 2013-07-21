require_relative '../core'


module Skylab::TestSupport::TestSupport

  TS_TS = self

  module CONSTANTS
    TS_TS = TS_TS
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  SYSTEM_ = TestSupport::Headless::System.defaults

end
