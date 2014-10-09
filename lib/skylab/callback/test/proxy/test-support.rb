require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Proxy

  ::Skylab::MetaHell::TestSupport[ TS_ = self ]

  ::Skylab::TestSupport::Sandbox::Host[ self ]

  module Sandbox
  end

  module CONSTANTS
    Sandbox = Sandbox
  end

  include CONSTANTS

  extend TestSupport_::Quickie  # brash

  -> do
    counter = 0
    define_singleton_method :next_id do counter += 1 end
  end.call
end
