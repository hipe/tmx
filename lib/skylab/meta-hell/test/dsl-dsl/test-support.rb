require_relative '../test-support'

module Skylab::MetaHell::TestSupport::DSL_DSL

  ::Skylab::MetaHell::TestSupport[ self ]

  include CONSTANTS

  MetaHell_ = ::Skylab::MetaHell

  extend TestSupport_::Quickie

  Sandboxer = TestSupport_::Sandbox::Spawner.new

end
