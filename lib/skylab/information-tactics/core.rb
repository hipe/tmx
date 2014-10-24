require_relative '../callback/core'

module Skylab::InformationTactics

  Callback_ = ::Skylab::Callback

    Autoloader_ = Callback_::Autoloader

  IT_ = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  IDENTITY_ = -> x { x }

end
