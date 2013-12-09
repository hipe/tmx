require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Client

  ::Skylab::Headless::TestSupport::CLI[ TS__ = self ]

  include CONSTANTS

  Headless = Headless

  extend TestSupport::Quickie

end
