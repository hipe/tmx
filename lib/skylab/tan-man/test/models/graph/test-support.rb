require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Graph

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  EMPTY_S_ = TanMan_::EMPTY_S_

  IDENTITY_ = -> x { x }

end
