require_relative '../test-support'

module Skylab::Headless::TestSupport::SubClient

  ::Skylab::Headless::TestSupport[ SubClient_TestSupport = self ] # #regret

  include CONSTANTS   # necessary to say `Headless` in the body of the spec

  extend TestSupport::Quickie

end
