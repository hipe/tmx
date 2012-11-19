require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport
  extend ::Skylab::TestSupport::Regret[ Headless_TestSupport = self ]

  module CONSTANTS
    Headless = ::Skylab::Headless
    Headless_TestSupport = Headless_TestSupport
  end

  include CONSTANTS   # necessary
  Headless = Headless # necessary

  module ModuleMethods
    def debug!
      let( :debug ) { true }
    end
  end

  module InstanceMethods # #bound to other subproducts!
    attr_accessor :debug

    def unstylize_if_stylized str
      Headless::CLI::IO::Pen::FUN.unstylize[ str ] or str
    end
  end
end
