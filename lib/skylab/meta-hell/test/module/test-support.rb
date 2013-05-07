require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Module
  ::Skylab::MetaHell::TestSupport[ self ] # #regret

  module CONSTANTS
    Module = MetaHell::Module
  end
end
