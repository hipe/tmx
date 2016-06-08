require_relative '../test-support'

module Skylab::Common::TestSupport::CallbackTree

  ::Skylab::Common::TestSupport[ self ]

  include Constants

  Home_ = Home_

  extend TestSupport_::Quickie

end
