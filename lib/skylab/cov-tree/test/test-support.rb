require_relative '../core'
require 'skylab/test-support/core'

::Skylab::TestSupport::Quickie.enable_kernel_describe
  # then we don't need to extend quick explicitly per test module ..
  # but this is just for easy legacy bridge-refactoring

module Skylab::CovTree::TestSupport

  ::Skylab::TestSupport::Regret[ CovTree_TestSupport = self ]

  # (move things up to here as appropriate if we ever build out the
  # non-cli portion of the app)

end
