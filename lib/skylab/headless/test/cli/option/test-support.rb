require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Option

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include CONSTANTS

  Headless_ = Headless_

   extend TestSupport_::Quickie

   Sandboxer = TestSupport_::Sandbox::Spawner.new

end
