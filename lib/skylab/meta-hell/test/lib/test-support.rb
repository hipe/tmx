require_relative '../test-support'

module Skylab::MetaHell::TestSupport

  module FUN

    ::Skylab::MetaHell::TestSupport[ self ]

    include CONSTANTS

    extend TestSupport_::Quickie

    MetaHell_ = MetaHell_

    Sandboxer = TestSupport_::Sandbox::Spawner.new

  end

  Fun = FUN  # #todo

end
