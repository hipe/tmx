require_relative '../test-support'

module Skylab::Headless::TestSupport::SubClient

  ::Skylab::Headless::TestSupport[ TS_ = self ] # #regret

  include Constants   # necessary to say Home_` in the body of the spec

  extend TestSupport_::Quickie

end
