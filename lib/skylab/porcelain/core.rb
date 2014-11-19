require_relative '..'
require 'skylab/callback/core'

module Skylab::Porcelain

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  def self._lib
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
      self::Lib_, self )
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Lib_, 'library-'

end
