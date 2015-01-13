require_relative '../test-support'

module Skylab::Callback::TestSupport::Actor

  ::Skylab::Callback::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Callback = Callback_

  Subject_ = -> do
    Callback_::Actor
  end
end
