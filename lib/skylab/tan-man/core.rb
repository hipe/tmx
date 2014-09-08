require_relative '..'
require 'skylab/brazen/core'

module Skylab::TanMan

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader
  Brazen_ = ::Skylab::Brazen
  TanMan_ = self

  Autoloader_[ self ]

  ACHEIVED_ = true
  EMPTY_S_ = ''.freeze
  stowaway :Entity_, 'models-'
  stowaway :Kernel_, 'models-'
  SPACE_ = ' '.freeze
  UNABLE_ = false

end
