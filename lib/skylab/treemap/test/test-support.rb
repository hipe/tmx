require_relative '../core'
require 'skylab/headless/test/test-support'  # give me h.l core *and* t.s core!!

module Skylab::Treemap::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    Headless = ::Skylab::Headless
    TestSupport = ::Skylab::TestSupport
    Treemap = ::Skylab::Treemap
  end

  include Constants

  extend ::Skylab::TestSupport::Quickie

end
