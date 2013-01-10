require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport
  ::Skylab::TestSupport::Regret[ Headless_TestSupport = self ]

  module CONSTANTS
    Headless = ::Skylab::Headless
    Headless_TestSupport = Headless_TestSupport
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS   # necessary
  Headless = Headless # necessary

  module ModuleMethods
    def debug!
      let( :do_debug ) { true }
    end
  end

  module InstanceMethods
    attr_accessor :do_debug

    def debug!
      self.do_debug = true
    end
  end
end
