require_relative '../test-support'

module Skylab::Callback::TestSupport::Autoloader

  ::Skylab::Callback::TestSupport[ TS_ = self ]

  include CONSTANTS

  Autoloader = Callback::Autoloader
  Callback = Callback

  extend TestSupport::Quickie

end
