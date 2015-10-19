require 'skylab/callback'

module Skylab::CodeMolester

  Callback_ = ::Skylab::Callback

  class << self

    def cache_path
      Home_.lib_.existent_cache_dir
    end

    def lib_
      @___lib ||= Home_::LIB_
    end
  end  # >>

  Autoloader_ = Callback_::Autoloader

  module Config
    Autoloader_[ self ]  # b.c of builtin class of same name :/
    Config_ = self
    Config = self  # for now for prettier treetop grammars
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  Home_ = self
  CLI = nil  # for host
  DID_ = true
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''.freeze
  stowaway :Library_, 'lib-'
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n".freeze
  NILADIC_EMPTINESS_ = -> { false }
  SPACE_ = ' '.freeze
  UNABLE_ = false

end
