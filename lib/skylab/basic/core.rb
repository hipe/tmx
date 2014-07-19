require_relative '../callback/core'

module Skylab::Basic  # introduction at [#020]

    Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader
  Basic = Basic_ = self
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :String, 'string/fun'

end
