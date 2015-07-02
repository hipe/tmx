require_relative '../test-support'

module Skylab::Callback::TestSupport::Autoloader

  ::Skylab::Callback::TestSupport[ TS_ = self ]

  Home_ = ::Skylab::Callback

  include Constants

  extend TestSupport_::Quickie

  Autoloader_ = Home_::Autoloader

  Subject_ = Autoloader_

end
