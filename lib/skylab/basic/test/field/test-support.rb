require_relative '../test-support'

module Skylab::Basic::TestSupport::Field

  ::Skylab::Basic::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  module Constants::Sandbox
  end

end
