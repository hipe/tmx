require_relative '../test-support'

module Skylab::TMX::TestSupport::CLI

  ::Skylab::TMX::TestSupport[ self ]

  include CONSTANTS

  Face::TestSupport::CLI::Client[ self ]  # tons of stuff from here

end
