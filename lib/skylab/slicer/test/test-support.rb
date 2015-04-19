require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Slicer::TestSupport

  Slicer_ = ::Skylab::Slicer
  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  Slicer_::Lib_::Face__[]::TestSupport::CLI::Client[ self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def client_class
      Slicer_::CLI::Client
    end
  end

  Benchmarks = ::Module.new

  module Constants
    Slicer_ = Slicer_
    TestSupport = TestSupport_
  end
end
