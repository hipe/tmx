require_relative '..'
require 'skylab/brazen/core'

module Skylab::TanMan

  class << self

    def name_function
      @nf ||= Callback_::Name.via_module self
    end

    def _lib
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
  Event_ = -> { Brazen_.event }
  FILE_SEPARATOR_ = ::File::SEPARATOR
  stowaway :Kernel_, 'models-'
  Model_lib_ = -> { Brazen_.model }
  NEWLINE_ = "\n".freeze
  Scan_ = -> & p do
    if p
      Callback_.scan( & p )
    else
      Callback_.scan
    end
  end

  SPACE_ = ' '.freeze
  TanMan_ = self
  UNABLE_ = false

end
