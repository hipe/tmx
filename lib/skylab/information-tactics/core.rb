require_relative '../callback/core'

module Skylab::InformationTactics

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader
  IT_ = self
  IDENTITY_ = -> x { x }

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]
end
