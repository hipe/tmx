require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services

  ::Skylab::Headless::TestSupport::System[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Subject____ = -> do
    Headless_::System__::Services__
  end

  Expect_event_ = -> x do
    TestLib_::Expect_event[ x ]
  end

  EMPTY_S_ = Headless_::EMPTY_S_
end
