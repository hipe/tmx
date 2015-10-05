require_relative '../test-support'

module Skylab::Basic::TestSupport::Hash

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  Subject_ = -> do
    Home_::Hash
  end
end
