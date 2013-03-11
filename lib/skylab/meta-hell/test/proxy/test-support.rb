require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Proxy

  ::Skylab::MetaHell::TestSupport[ Proxy_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie  # brash

  -> do
    counter = 0
    define_singleton_method :next_id do counter += 1 end
  end.call
end
