require_relative '../test-support'

module Skylab::BeautySalon::TestSupport::CLI

  ::Skylab::BeautySalon::TestSupport[ self ]

  include CONSTANTS

  Face::TestSupport::CLI::Client[ self ]

end
