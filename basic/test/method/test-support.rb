require_relative '../test-support'

module Skylab::Basic::TestSupport::Method

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  Home_ = Home_

  extend TestSupport_::Quickie

  Sandboxer = TestSupport_::Sandbox::Spawner.new

end
