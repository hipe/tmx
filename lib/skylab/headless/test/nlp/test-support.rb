require_relative '../test-support'

module Skylab::Headless::TestSupport::NLP

  ::Skylab::Headless::TestSupport[ TS_ = self ] # #regret

  module CONSTANTS
    Headless_::NLP || nil
  end

  include CONSTANTS   # necessary to say Headless_` in the body of the spec

  TestSupport_::Quickie.enable_kernel_describe

end
