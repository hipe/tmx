require_relative '../test-support'

module Skylab::MetaHell::TestSupport::FUN::Parse

  ::Skylab::MetaHell::TestSupport::FUN[ self ]

  include CONSTANTS

  MetaHell = MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

end
