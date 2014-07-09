require_relative '..'
require 'skylab/callback/core'

module Skylab::Porcelain

  Callback = ::Skylab::Callback
    Autoloader_ = Callback::Autoloader

  o = Autoloader_.method :require_sidesystem

  Headless = o[ :Headless ] # headless in porcelain yes. headles trumps porcelain.

  Porcelain = self
  Porcelain_ = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  IDENTITY_ = -> x { x }

  EMPTY_P_ = -> { }

  stowaway :Lib_, 'library-'

end
