require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Slicer::TestSupport

  ::Skylab::TestSupport::Regret[ Slicer_TestSupport = self ]

  module Constants
    Slicer_ = ::Skylab::Slicer
    TestSupport = ::Skylab::TestSupport
  end

  include Constants

  Slicer_::Lib_::Face__[]::TestSupport::CLI::Client[ self ]

  extend TestSupport::Quickie

  module ModuleMethods
    include Constants
    def client_class
      Slicer_::CLI::Client
    end
  end
end
