require_relative '..'
require 'skylab/brazen/core'

module Skylab::TanMan

  class << self

    def name_function
      @nf ||= Callback_::Name.via_module self
    end

    def lib_
      @lib ||= TanMan_::Lib_::INSTANCE
    end
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self ]

  Brazen_ = ::Skylab::Brazen
  ACHIEVED_ = true
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  stowaway :Entity_, 'models-'
  FILE_SEPARATOR_ = ::File::SEPARATOR
  stowaway :Kernel_, 'models-'
  Model_lib_ = -> { Brazen_.model }
  NEWLINE_ = "\n".freeze
  SPACE_ = ' '.freeze
  TanMan_ = self
  UNABLE_ = false

end
