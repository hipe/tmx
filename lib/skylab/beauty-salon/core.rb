require_relative '..'
require 'skylab/callback/core'

module Skylab::BeautySalon

  module API

    class << self

      def call * x_a, & oes_p
        bc = BS_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def call_via_mutable_box__ * i_a, bx, & x_p
        bc = BS_.application_kernel_.bound_call_via_mutable_box i_a, bx, & x_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end
    end  # >>
  end

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Brazen_::Kernel.new BS_
    end )

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules( Lib_, self )
    end

    def search_and_replace
      BS_::Models_::Search_and_Replace
    end
  end  # >>

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Brazen = -> do  # not until we're sure
      Brazen_
    end

    CLI_lib = -> do
      HL___[]::CLI
    end

    File_utils = Callback_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    Face__ = sidesys[ :Face ]

    HL___ = sidesys[ :Headless ]

    List_scanner = -> x do
      Callback_::Scn.try_convert x
    end

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
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

    Token_buffer = -> x, y do
      Basic[]::Token::Buffer.new x, y
    end

    Tree_lib = -> do
      ST__[]::Tree
    end
  end

  ACHIEVED_ = true
  Brazen_ = Autoloader_.require_sidesystem :Brazen
  BS_ = self
  CONST_SEP_ = '::'.freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }          # for fun we track this
  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]  # ask for it
  NEWLINE_ = "\n"
  NIL_ = nil  # to emphasize its use
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false
  THE_EMPTY_MODULE_ = ::Module.new.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

end
