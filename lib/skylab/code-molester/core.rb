require_relative '../callback/core'

module Skylab::CodeMolester

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader
  CodeMolester = self
  EMPTY_A_ = [].freeze
  MONADIC_TRUTH_ = -> _ { true }

  module Model
    Autoloader_[ self ]
    stowaway :Event, 'config/controller'
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Lib_, 'library-'

end
