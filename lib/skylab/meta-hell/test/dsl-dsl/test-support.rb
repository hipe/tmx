require_relative '../test-support'

module Skylab::MetaHell::TestSupport::DSL_DSL

  ::Skylab::MetaHell::TestSupport[ self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

end
