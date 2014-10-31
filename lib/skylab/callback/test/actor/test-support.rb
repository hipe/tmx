require_relative '../test-support'

module Skylab::Callback::TestSupport::Actor

  ::Skylab::Callback::TestSupport[ self ]

  include Constants

  Callback = Callback_

  Subject_ = -> do
    Callback_::Actor
  end
end
