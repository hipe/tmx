require_relative '..'
require_relative '../callback/core'

module Skylab::Brazen

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module Data_Stores_
    Autoloader_[ self, :boxxy ]
  end

  module Lib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    Headless__ = sidesys[ :Headless ]
    N_lines = -> do
      Brazen_::Entity::Event::N_Lines
    end
    Name_function_methods = -> do
      Snag__[]::Model_.name_function_methods
    end
    NLP = -> do
      Headless__[]::NLP
    end
    IO = -> do
      Headless__[]::IO
    end
    Snag__ = sidesys[ :Snag ]
    Text = -> do
      Snag__[]::Text
    end
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Brazen_ = self
  DONE_ = true
  EMPTY_S_ = ''.freeze
  Entity_ = -> { Brazen_::Entity }
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  NILADIC_TRUTH_ = -> { true }
  SLASH_ = '/'.getbyte 0
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
