require_relative '../test-support'

module Skylab::Common::TestSupport::Scn

  ::Skylab::Common::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Home_::Autoloader.require_sidesystem :Basic

  Home_ = Home_

end
