require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/core'  # unstylize etc

module Skylab::PubSub::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    Headless = ::Skylab::Headless
    PubSub = ::Skylab::PubSub  # required by sub-nodes
    TestSupport = ::Skylab::TestSupport  # le balls
  end

  Headless = CONSTANTS::Headless  # so that h.l is visible in all modules
                                  # lexically scoped under this one.
                                  # (necessary for e.g in Nub)

end
