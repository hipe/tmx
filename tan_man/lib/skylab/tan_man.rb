require 'skylab/brazen'

module Skylab::TanMan

  def self.describe_into_under y, _
    y << "manage your tangents visually"
  end

  Common_ = ::Skylab::Common

  class << self

    define_method :application_kernel_, ( Common_.memoize do
      Brazen_::Kernel.new Home_
    end )

    def lib_
      @lib ||= Home_::Lib_::INSTANCE
    end

    def name_function
      @nf ||= Common_::Name.via_module self
    end

    def sidesystem_path_
      @___sidesys_path ||= ::File.expand_path( '../../..', __FILE__ )
    end
  end  # >>

  Autoloader_ = Common_::Autoloader

  module Input_Adapters_
    Autoloader_[ self ]
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

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
