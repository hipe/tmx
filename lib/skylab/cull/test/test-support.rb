require_relative '../core'
require 'skylab/face/test/cli/test-support'

module Skylab::Cull::TestSupport
  ::Skylab::TestSupport::Regret[ Cull_TestSupport = self ]
  ::Skylab::Face::TestSupport::CLI[ self ]

  module CONSTANTS
    Cull = ::Skylab::Cull
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie

  module ModuleMethods
    include CONSTANTS
    def client_class
      Cull::CLI  # not actually!
    end
  end
end
