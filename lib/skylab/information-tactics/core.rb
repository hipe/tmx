require_relative '../callback/core'

module Skylab::InformationTactics

  Autoloader_ = ::Skylab::Callback::Autoloader

  InformationTactics = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

end
