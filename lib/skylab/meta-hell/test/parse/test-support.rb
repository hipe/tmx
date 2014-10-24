require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Parse

  ::Skylab::MetaHell::TestSupport[ self ]

  include Constants

  MetaHell_ = MetaHell_

  extend TestSupport_::Quickie

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  Subject_ = -> do
    MetaHell_::Parse
  end
end
