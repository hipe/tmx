require_relative '..'
require 'skylab/callback/core'

module Skylab::Slake

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  module Lib_  # :+[#su-001]
    sidesys = Autoloader_.build_require_sidesystem_proc
    Formal_attribute = -> do
      MetaHell__[]::Formal::Attribute
    end
    MetaHell__ = sidesys[ :MetaHell ]
    StringIO = -> do
      require 'stringio' ; ::StringIO
    end
  end

  Slake_ = self
end
