require_relative '../test-support'

module Skylab::Callback::TestSupport::Proxy

  ::Skylab::Callback::TestSupport[ TS_ = self ]

  define_singleton_method :next_id, -> do
    counter = 0
    -> do
      counter += 1
    end
  end.call

  include Constants

  extend TestSupport_::Quickie

  TestSupport_::Sandbox::Host[ self ]

  Sandbox = ::Module.new

  Sandbox.name  # covered :(

  module Constants
    Sandbox = Sandbox
  end

  Subject_ = -> do
    Home_::Proxy
  end
end
