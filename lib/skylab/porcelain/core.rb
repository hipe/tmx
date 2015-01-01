require_relative '..'
require 'skylab/callback/core'

module Skylab::Porcelain

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  def self.lib_
    @lib ||= Porcelain_::Lib_::INSTANCE
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Lib_, 'library-'

  Porcelain_ = self

end
