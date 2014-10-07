require_relative '../test-support'

module Skylab::Basic::TestSupport::Hash

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Basic_ = Basic_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

end
