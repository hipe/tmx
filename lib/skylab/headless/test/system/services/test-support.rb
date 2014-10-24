require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services

  ::Skylab::Headless::TestSupport::System[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Subject____ = -> do
    Headless_::System__::Services__
  end
end
