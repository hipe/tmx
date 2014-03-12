require_relative '../test-support'

module Skylab::Face::TestSupport::CLI::Table

  ::Skylab::Face::TestSupport[ self, :flight_of_stairs ]

  def self.bundles_class
    parent_anchor_module.bundles_class
  end

  include CONSTANTS

  extend TestSupport::Quickie

  Face = Face

  Sandboxer = TestSupport::Sandbox::Spawner.new

end
