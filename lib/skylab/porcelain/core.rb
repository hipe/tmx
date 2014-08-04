require_relative '..'
require 'skylab/callback/core'

module Skylab::Porcelain

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Porcelain_ = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Lib_, 'library-'

end
