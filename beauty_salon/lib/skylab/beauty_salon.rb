require 'skylab/common'

module Skylab::BeautySalon

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

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

  lazily :CLI do
    class CLI < Home_.lib_.brazen::CLI

      expose_executables_with_prefix 'tmx-beauty-salon-'

      self
    end
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

  module Models_

    Autoloader_[ self, :boxxy ]

    stowaway :Text, 'text/actions/wrap'
  end

  Lazy_ = Common_::Lazy

  Require_brazen_LEGACY_ = Lazy_.call do
    Brazen_ = Home_.lib_.brazen
    NIL
  end

  module Lib_

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    File_utils = Common_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    List_scanner = -> x do
      Common_::Stream::Magnetics::MinimalStream_via[ x ]
    end

    String_scanner = Common_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    Token_buffer = -> x, y do
      Basic[]::Token::Buffer.new x, y
    end

    Tree_lib = -> do
      ST__[]::Tree
    end

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    ST__ = sidesys[ :SubTree ]
    System_lib = sidesys[ :System ]
    Zerk = sidesys[ :Zerk ]
  end

  ACHIEVED_ = true
  Home_ = self
  CONST_SEP_ = '::'.freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }          # for fun we track this
  NEWLINE_ = "\n"
  NIL_ = nil  # to emphasize its use
  NIL = nil  # #open [#sli-116.C]
  NOTHING_ = nil
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false
  THE_EMPTY_MODULE_ = ::Module.new.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
