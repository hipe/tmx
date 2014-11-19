require_relative '..'
require 'skylab/callback/core'

module Skylab::Slake

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  def self._lib
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  end

  module Lib_  # :+[#su-001]

    sidesys = Autoloader_.build_require_sidesystem_proc

    Formal_attribute = -> do
      MH__[]::Formal::Attribute
    end

    MH__ = sidesys[ :MetaHell ]

    String_IO = -> do
      require 'stringio' ; ::StringIO
    end
  end

  Slake_ = self
end
