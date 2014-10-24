require_relative '../test-support'

module Skylab::Face::TestSupport::CLI::Table

  ::Skylab::Face::TestSupport[ self, :flight_of_stairs ]

  def self.bundles_class
    parent_anchor_module.bundles_class
  end

  include Constants

  extend TestSupport_::Quickie

  Face_ = Face_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  Subject__ = -> { Face_::CLI::Table }

end
