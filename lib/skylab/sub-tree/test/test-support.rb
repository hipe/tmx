require_relative '../core'
require 'skylab/test-support/core'

Skylab::TestSupport::Quickie.enable_kernel_describe
  # then we don't need to extend quick explicitly per test module ..
  # but this is just for easy legacy bridge-refactoring

module Skylab::SubTree::TestSupport

  module CONSTANTS
    ::Skylab::MetaHell::FUN::
      Import_constants[ ::Skylab, %i( MetaHell SubTree TestSupport ), self ]
  end

  include CONSTANTS

  TestSupport = TestSupport

  TestSupport::Regret[ self ]

  module InstanceMethods

    def debug_stream
      TestSupport::Stderr_[]
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end
  end
end
