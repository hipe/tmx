require_relative '../core'
require 'skylab/test-support/core'

module Skylab::TMX::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

end
