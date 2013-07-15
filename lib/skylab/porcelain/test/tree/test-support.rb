require_relative '../../core'  # just to be jerks we are leaving some legacy
require 'skylab/test-support/core'  # artifacts laying around. set it up anew
                                         # from this node on down
module Skylab::Porcelain::TestNamespace

  Porcelain = ::Skylab::Porcelain
  Tree = ::Skylab::Porcelain::Tree

  extend ::Skylab::TestSupport::Quickie

end
