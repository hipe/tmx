require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Ivars_with_Procs_as_Methods

  ::Skylab::MetaHell::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  Subject_ = -> * a do
    MetaHell_::Ivars_with_Procs_as_Methods.via_arglist a
  end
end
