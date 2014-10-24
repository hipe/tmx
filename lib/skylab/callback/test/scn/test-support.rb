require_relative '../test-support'

module Skylab::Callback::TestSupport::Scn

  ::Skylab::Callback::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Callback_::Autoloader.require_sidesystem :Basic

  Callback_ = Callback_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

end
