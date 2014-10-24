require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Option

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include Constants

  extend TestSupport_::Quickie

  Headless_ = Headless_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  Subject_ = -> do
    Headless_::CLI.option
  end
end
