require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Semantic::TestSupport
  # ::Skylab::TestSupport::Regret[ self ] (not actually necessary yet)

  include ::Skylab # e.g `TestSupport`, `Semantic`

  extend TestSupport::Quickie

end
