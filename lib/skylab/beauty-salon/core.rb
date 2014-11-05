require_relative '..'
require 'skylab/callback/core'

module Skylab::BeautySalon

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    API_Action = -> do
      Face__[]::API::Action
    end

    Brazen = sidesys[ :Brazen ]

    Bsc__ = sidesys[ :Basic ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    Face__ = sidesys[ :Face ]

    HL__ = sidesys[ :Headless ]

    Ivars_with_procs_as_methods = -> do
      MH__[]::Ivars_with_Procs_as_Methods
    end

    List_scanner = -> x do
      Callback_::Scn.try_convert x
    end

    MH__ = sidesys[ :MetaHell ]

    Old_CLI_lib = -> do
      Face__[]::CLI
    end

    Plugin = -> do
      Face__[]::Plugin
    end

    Range_lib = -> do
      Bsc__[]::Range
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Regexp_lib = -> do
      Bsc__[]::Regexp
    end

    System = -> do
      HL__[].system
    end

    Token_buffer = -> x, y do
      Bsc__[]::Token::Buffer.new x, y
    end
  end

  # (:+[#su-001]:none)

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  ACHIEVED_ = true
  BS_ = self
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }          # for fun we track this
  READ_MODE_ = 'r'.freeze
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  UNABLE_ = false

end
