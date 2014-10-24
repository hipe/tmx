require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Lib

  ::Skylab::MetaHell::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

end
