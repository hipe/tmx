require_relative '..'
require 'skylab/brazen/core'

module Skylab::TanMan

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self ]

  Brazen_ = ::Skylab::Brazen
  ACHEIVED_ = true
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  stowaway :Entity_, 'models-'
  Event_ = -> { Brazen_::Entity.event }
  stowaway :Kernel_, 'models-'
  Model_lib_ = -> { Brazen_.model }

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
