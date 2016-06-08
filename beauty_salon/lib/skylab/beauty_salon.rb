require 'skylab/common'

module Skylab::BeautySalon

  Common_ = ::Skylab::Common

  class << self

    def describe_into_under y, _

      y << "an umbrella node for text-processing utilities -"
      y << "word wrap, search & replace, and comment processing functions"
    end

    define_method :application_kernel_, ( Common_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  stowaway :CLI do

    CLI = ::Class.new Home_.lib_.brazen::CLI
  end

  module API

    class << self

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def call_via_mutable_box__ * i_a, bx, & x_p
        bc = Home_.application_kernel_.bound_call_via_mutable_box i_a, bx, & x_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end
    end  # >>
  end

  module Lib_

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    File_utils = Common_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    List_scanner = -> x do
      Common_::Scn.try_convert x
    end

    ST__ = sidesys[ :SubTree ]

    String_scanner = Common_.memoize do
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

    Zerk = sidesys[ :Zerk ]
  end

  ACHIEVED_ = true
  Home_ = self
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

end
