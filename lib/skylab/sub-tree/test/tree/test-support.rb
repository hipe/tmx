require_relative '../test-support'

module Skylab::SubTree::TestSupport::Tree

  ::Skylab::SubTree::TestSupport[ self ]

  include CONSTANTS

  module CONSTANTS
    Subject_ = -> do
      SubTree_::Tree
    end
  end
end

# #tombstone legacy artifacts of early early test setup
