require_relative '..'
require 'skylab/callback/core'

module Skylab::Git

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Git_ = self

  stowaway :Lib_, 'library-'
end
