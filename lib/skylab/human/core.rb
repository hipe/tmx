require_relative '../callback/core'

module Skylab::Human  # :[#001].

  class << self

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  EMPTY_S_ = ''
  Hu_ = self
  IDENTITY_ = -> x { x }
  SPACE_ = ' '

end
