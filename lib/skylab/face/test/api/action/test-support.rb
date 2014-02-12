require_relative '../test-support'

module Skylab::Face::TestSupport::API::Action

  ::Skylab::Face::TestSupport::API[ self, :flight_of_stairs ]

  def self.bundles_class
    parent_anchor_module.bundles_class
  end
end
