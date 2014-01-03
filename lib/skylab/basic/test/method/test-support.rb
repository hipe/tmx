require_relative '../test-support'

module Skylab::Basic::TestSupport::Method

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  Basic = Basic

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

end
