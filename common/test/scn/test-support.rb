require_relative '../test-support'

module Skylab::Callback::TestSupport::Scn

  ::Skylab::Callback::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Home_::Autoloader.require_sidesystem :Basic

  Home_ = Home_

end
