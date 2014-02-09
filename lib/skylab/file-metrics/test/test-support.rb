require_relative '../core'
require 'skylab/test-support/core'

module Skylab::FileMetrics

  module TestSupport
    ::Skylab::TestSupport::Regret[ self ]

    module CONSTANTS
      FileMetrics = ::Skylab::FileMetrics
      Lib_ = FileMetrics::Lib_
      TestSupport = ::Skylab::TestSupport
    end
  end
end
