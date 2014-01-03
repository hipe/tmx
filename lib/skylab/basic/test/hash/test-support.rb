require_relative '../test-support'

module Skylab::Basic::TestSupport::Hash

  ::Skylab::Basic::TestSupport[ Hash_TestSupport = self ]

  include CONSTANTS

  Basic = Basic

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

end
