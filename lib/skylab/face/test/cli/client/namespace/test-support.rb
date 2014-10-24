require_relative '../test-support'

module Skylab::Face::TestSupport::CLI::Client::Namespace

  ::Skylab::Face::TestSupport::CLI::Client[ self, :flight_of_stairs ]

  module Constants
    Sandbox = CLI_Client_TS_::Sandbox  # please be careful
  end

  def self.bundles_class
    parent_anchor_module.bundles_class
  end
end
