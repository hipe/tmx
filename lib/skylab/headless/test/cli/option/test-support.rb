require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Option

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  Subject_ = -> do
    Home_::CLI.option
  end
end
