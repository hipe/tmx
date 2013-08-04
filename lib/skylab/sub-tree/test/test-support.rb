require_relative '../core'
require 'skylab/test-support/core'

::Skylab::TestSupport::Quickie.enable_kernel_describe
  # then we don't need to extend quick explicitly per test module ..
  # but this is just for easy legacy bridge-refactoring

module Skylab::SubTree::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    ::Skylab::MetaHell::FUN.
      import[ self, ::Skylab, %i( MetaHell SubTree TestSupport ) ]
  end
end
