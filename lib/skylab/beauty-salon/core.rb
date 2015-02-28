require_relative '..'
require 'skylab/callback/core'

module Skylab::BeautySalon

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  def self.lib_
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules( Lib_, self )
  end

  Brazen_ = Autoloader_.require_sidesystem :Brazen

  module API

    extend Brazen_::API.module_methods

  end

  class Kernel_ < Brazen_::Kernel_  # :+[#br-015]

  end

  THE_EMPTY_MODULE_ = ::Module.new.freeze

  module Models_
    Autoloader_[ self, :boxxy ]  # ask for it
  end

  module Lib_

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Brazen = -> do  # not until we're sure
      Brazen_
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    File_utils = Callback_.memoize do
      require 'fileutils'
      ::FileUtils
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

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Shellwords = -> do
      require 'shellwords'
      ::Shellwords
    end

    ST__ = sidesys[ :SubTree ]

    String_scanner = Callback_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      HL__[].system
    end

    Token_buffer = -> x, y do
      Basic[]::Token::Buffer.new x, y
    end

    Tree_lib = -> do
      ST__[]::Tree
    end
  end

  # (:+[#su-001]:none)

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  ACHIEVED_ = true
  BS_ = self
  CONST_SEP_ = '::'.freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }          # for fun we track this
  NEWLINE_ = "\n"
  NIL_ = nil  # to emphasize its use
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
