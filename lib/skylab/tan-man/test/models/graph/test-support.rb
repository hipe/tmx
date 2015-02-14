require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Graph

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  IDENTITY_ = -> x { x }

  READ_MODE_ = 'r'.freeze

  WRITE_MODE_ = 'w'.freeze

end
