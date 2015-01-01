require_relative '../callback/core'

module Skylab::CodeMolester

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  class << self
    def cache_pathname
      CM_.lib_.cache_pathname_base
    end

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end

  module Config
    Autoloader_[ self ]  # b.c of builtin class of same name :/
    Config_ = self
    Config = self  # for now for prettier treetop grammars
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  CM_ = self
  DID_ = true
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''.freeze
  stowaway :Lib_, 'library-'
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n".freeze
  NILADIC_EMPTINESS_ = -> { false }
  SPACE_ = ' '.freeze
  UNABLE_ = false

end
