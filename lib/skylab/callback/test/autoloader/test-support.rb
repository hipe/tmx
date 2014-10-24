require_relative '../test-support'

module Skylab::Callback::TestSupport::Autoloader

  ::Skylab::Callback::TestSupport[ TS_ = self ]

  Callback_ = ::Skylab::Callback

  include Constants

  extend TestSupport_::Quickie

  Autoloader_ = Callback_::Autoloader

  Subject_ = Autoloader_

end
