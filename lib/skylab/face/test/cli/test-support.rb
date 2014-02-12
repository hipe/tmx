require_relative '../test-support'

module Skylab::Face::TestSupport::CLI

  ::Skylab::Face::TestSupport[ self, :flight_of_stairs ]

  def self.bundles_class
    parent_anchor_module.bundles_class
  end

  stowaway :Client, 'client/test-support'  # [#045] this is part of our public API
end
