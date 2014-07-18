require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Parse

  ::Skylab::MetaHell::TestSupport[ self ]

  include CONSTANTS

  MetaHell = MetaHell_

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

end
