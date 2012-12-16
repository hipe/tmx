require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport
  ::Skylab::TestSupport::Regret[ Headless_TestSupport = self ]

  module CONSTANTS
    Headless = ::Skylab::Headless
    Headless_TestSupport = Headless_TestSupport
    MetaHell = ::Skylab::MetaHell
  end

  include CONSTANTS   # necessary
  Headless = Headless # necessary

  module ModuleMethods
    def debug!
      let( :debug ) { true }
    end
  end
end
