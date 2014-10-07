require_relative '../test-support'

module Skylab::Basic::TestSupport::Method

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  Basic_ = Basic_

  extend TestSupport_::Quickie

  Sandboxer = TestSupport_::Sandbox::Spawner.new

end
