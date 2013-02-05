require_relative '../core'
require 'skylab/headless/test/test-support'  # give me h.l core *and* t.s core!!

module Skylab::Treemap::TestSupport
  ::Skylab::TestSupport::Regret[ Treemap_TestSupport = self ]

  module CONSTANTS
    Headless = ::Skylab::Headless
    TestSupport = ::Skylab::TestSupport
    Treemap = ::Skylab::Treemap
  end

  include CONSTANTS

  extend ::Skylab::TestSupport::Quickie

end
