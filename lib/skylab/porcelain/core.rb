require_relative '..'
require 'skylab/callback/core'

module Skylab::Porcelain

  class << self

    def lib_
      @lib ||= Porcelain_::Lib_::INSTANCE
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader
  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  stowaway :Lib_, 'library-'
  Porcelain_ = self

end
