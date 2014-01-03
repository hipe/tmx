require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Option

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include CONSTANTS

   Headless = Headless

   extend TestSupport::Quickie

   Sandboxer = TestSupport::Sandbox::Spawner.new

end
