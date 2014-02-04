require_relative '../test-support'

module Skylab::Headless::TestSupport::Plugin

  ::Skylab::Headless::TestSupport[ TS__ = self ]

  include CONSTANTS

  Headless = Headless
  Callback = Headless::Library_::Callback

  extend TestSupport::Quickie

end
