require_relative '../core'
require 'skylab/test-support/core'

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
