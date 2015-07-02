require_relative '../test-support'

module Skylab::Basic::TestSupport::String

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  module Constants
    EMPTY_S_ = Home_::String::EMPTY_S_
  end

  EMPTY_S_ = EMPTY_S_

  SPACE_ = ' '.freeze  # don't load anything

end
