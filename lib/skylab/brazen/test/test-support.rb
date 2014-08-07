require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Brazen::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ self ]

  module CONSTANTS
    Brazen_ = ::Skylab::Brazen
    EMPTY_S_ = ''
    TestSupport_ = TestSupport_
  end
end
