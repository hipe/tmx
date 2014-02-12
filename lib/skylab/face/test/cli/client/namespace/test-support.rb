require_relative '../test-support'

module Skylab::Face::TestSupport::CLI::Namespace

  ::Skylab::Face::TestSupport::CLI[ TS__ = self ]

  CONSTANTS::Common_setup_[ self ]

  module CONSTANTS
    Sandbox = CLI_TestSupport::Sandbox  # please be careful
  end

end
