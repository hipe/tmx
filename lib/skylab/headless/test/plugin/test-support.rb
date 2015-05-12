require_relative '../test-support'

module Skylab::Headless::TestSupport::Plugin

  ::Skylab::Headless::TestSupport[ TS__ = self ]

  include Constants

  Headless_ = Headless_

  Callback_ = Headless_::Callback_

  extend TestSupport_::Quickie

end
