require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Slicer::TestSupport

  ::Skylab::TestSupport::Regret[ Slicer_TestSupport = self ]

  module CONSTANTS
    Face = ::Skylab::Face
    Slicer = ::Skylab::Slicer
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  Face::TestSupport::CLI::Client[ self ]

  extend TestSupport::Quickie

  module ModuleMethods
    include CONSTANTS
    def client_class
      Slicer::CLI::Client
    end
  end
end
