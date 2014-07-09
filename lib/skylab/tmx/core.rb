require_relative '..'
require 'skylab/callback/core'

module Skylab::TMX

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  module CLI  # #stowaway
    def self.new *a
      self::Client.new( *a )
    end
    Autoloader_[ self ]
  end

  CLI_Client_ = -> do
    Lib_::Face__[]::CLI::Client
  end

  module Lib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    Constantize = -> i do
      ::Skylab::Autoloader::FUN::Constantize[ i ]
    end
    Distill = -> i do
      Callback_::Distill_[ i ]
    end
    Face__ = sidesys[ :Face ]
    MetaHell__ = sidesys[ :MetaHell ]
    Proxy = -> do
      MetaHell__[]::Proxy
    end
  end

  TMX = self  # not 'TMX_', just for aesthetics

  # (:+[#su-001]:none)
end
