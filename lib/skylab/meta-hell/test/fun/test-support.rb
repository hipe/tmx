require_relative '../test-support'

module Skylab::MetaHell::TestSupport

  module FUN

    ::Skylab::MetaHell::TestSupport[ self ]

    include CONSTANTS

    MetaHell = MetaHell

    extend TestSupport::Quickie

    Sandboxer = TestSupport::Sandbox::Spawner.new

  end

  Fun = FUN  # #todo

end
