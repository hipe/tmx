require_relative '../test-support'

module Skylab::Headless::TestSupport::Plugin

  ::Skylab::Headless::TestSupport[ TS__ = self ]

  include CONSTANTS

  Headless_ = Headless_
  Callback = Headless_::Library_::Callback

  extend TestSupport_::Quickie

end
