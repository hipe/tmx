require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Parse

  ::Skylab::MetaHell::TestSupport[ self ]

  include CONSTANTS

  MetaHell_ = MetaHell_

  extend TestSupport_::Quickie

  Sandboxer = TestSupport_::Sandbox::Spawner.new

end
