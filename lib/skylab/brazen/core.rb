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
    Name = -> do
      Callback_::Name
    end
  end
end
