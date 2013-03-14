require_relative '../core'
require 'skylab/test-support/core'

::Skylab::TestSupport::Quickie.enable_kernel_describe  # (should always be

module Skylab::CovTree::TestSupport
  ::Skylab::TestSupport::Regret[ CovTree_TestSupport = self ]

  # (move things up to here as appropriate if we ever build out the
  # non-cli portion of the app)

end
