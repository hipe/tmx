require_relative '..'
require 'skylab/callback/core'

module Skylab::Snag

  class << self

    def lib_
      @lib ||= Snag_::Lib_.instance
    end

  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Models_
    Autoloader_[ self, :boxxy ]
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_= true
  Bsc__ = Autoloader_.build_require_sidesystem_proc :Basic
  Bzn__ = Autoloader_.build_require_sidesystem_proc :Brazen
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }
  stowaway :Library_, 'lib-'
  LINE_SEP_ = "\n".freeze
  NIL_ = nil
  KEEP_PARSING_ = true
  NEUTRAL_ = nil
  Snag_ = self
  SPACE_ = ' '.freeze
  UNABLE_ = false
end
