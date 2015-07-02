require_relative '../test-support'

module Skylab::Callback::TestSupport::Actor

  ::Skylab::Callback::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Callback = Home_

  Subject_ = -> do
    Home_::Actor
  end
end
