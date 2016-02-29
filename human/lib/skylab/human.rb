require 'skylab/callback'

module Skylab::Human  # :[#001].

  class << self

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module NLP
    Autoloader_[ self ]
    NLP_ = self
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''
  Home_ = self
  IDENTITY_ = -> x { x }
  Lazy_ = Callback_::Lazy
  NIL_ = nil
  NONE_ = nil
  KEEP_PARSING_ = true
  SPACE_ = ' '
  UNDERSCORE_ = '_'
end
