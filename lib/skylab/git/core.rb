require_relative '..'
require 'skylab/callback/core'

module Skylab::Git

  class << self
    def check_SCM * a
      if a.length.zero?
        Git_::Actors__::Check_SCM
      else
        Git_::Actors__::Check_SCM[ * a ]
      end
    end
  end


  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Git_ = self

  stowaway :Lib_, 'library-'
end
