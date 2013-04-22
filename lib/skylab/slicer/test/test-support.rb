require_relative '../core'
require 'skylab/face/test/cli/test-support'

module Skylab::Slicer::TestSupport
  ::Skylab::TestSupport::Regret[ Slicer_TestSupport = self ]
  ::Skylab::Face::TestSupport::CLI[ self ]

  module CONSTANTS
    Slicer = ::Skylab::Slicer
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie

  module ModuleMethods
    include CONSTANTS
    def client_class
      Slicer::CLI::Client
    end
  end
end
