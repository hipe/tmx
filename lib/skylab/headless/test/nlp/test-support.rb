require_relative '../test-support'

module Skylab::Headless::TestSupport::NLP
  ::Skylab::Headless::TestSupport[ NLP_TestSupport = self ] # #regret

  module CONSTANTS
    Headless::NLP || nil
    include Headless  # ( but note it prevents us from saying T_S )
  end

  include CONSTANTS   # necessary to say `Headless` in the body of the spec
end
