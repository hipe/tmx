require_relative '..'
require_relative '../callback/core'

module Skylab::Brazen

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Brazen_ = self

  module Actions_
    Autoloader_[ self, :boxxy ]
  end

  module Lib_
    N_lines = -> do
      Brazen_::Entity::Event::N_Lines
    end
    Name = -> do
      Callback_::Name
    end
  end

  NILADIC_TRUTH_ = -> { true }
  SLASH_ = '/'.getbyte 0
  SPACE_ = ' '.freeze
  UNDERSCORE_ = '_'.freeze

end
