require_relative '../test-support'

module Skylab::Headless::TestSupport::Plugin

  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS

  Headless = Headless

  extend TestSupport::Quickie

end
