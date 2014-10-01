require_relative '../test-support'

module Skylab::Headless::TestSupport::SubClient

  ::Skylab::Headless::TestSupport[ TS_ = self ] # #regret

  include CONSTANTS   # necessary to say Headless_` in the body of the spec

  extend TestSupport_::Quickie

end
