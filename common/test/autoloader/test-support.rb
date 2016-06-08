require_relative '../test-support'

module Skylab::Common::TestSupport::Autoloader

  ::Skylab::Common::TestSupport[ TS_ = self ]

  Home_ = ::Skylab::Common

  include Constants

  extend TestSupport_::Quickie

  Autoloader_ = Home_::Autoloader

  Subject_ = Autoloader_

end
