require_relative '../test-support'

module Skylab::Basic::TestSupport::List

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  Subject_ = -> do
    Home_::List
  end
end
