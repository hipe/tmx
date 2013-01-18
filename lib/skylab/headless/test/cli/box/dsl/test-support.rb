require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL
  ::Skylab::Headless::TestSupport::CLI::Box[ DSL_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie
end
