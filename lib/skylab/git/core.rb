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

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  DASH_ = '-'.freeze
  Git_ = self
  stowaway :Lib_, 'library-'
  UNDERSCORE_ = '_'.freeze

end
