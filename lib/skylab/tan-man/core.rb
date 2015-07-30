require_relative '..'
require 'skylab/brazen/core'

module Skylab::TanMan

  def self.describe_into_under y, _
    y << "manage your tangents visually"
  end

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Brazen_::Kernel.new Home_
    end )

    def lib_
      @lib ||= Home_::Lib_::INSTANCE
    end

    def name_function
      @nf ||= Callback_::Name.via_module self
    end
  end  # >>

  Autoloader_ = Callback_::Autoloader

  module Input_Adapters_
    Autoloader_[ self ]
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  Brazen_ = ::Skylab::Brazen
  CONST_SEP_ = '::'.freeze
  DASH_ = '-'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  stowaway :Entity_, 'models-'
  FILE_SEPARATOR_ = ::File::SEPARATOR
  stowaway :Kernel_, 'models-'
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  SPACE_ = ' '.freeze
  Home_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
