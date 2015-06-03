require_relative '..'

require_relative '../callback/core'

module Skylab::Brazen

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Brazen_::Kernel.new Brazen_
    end )

    def byte_downstream_identifier
      Brazen_::Collection::Byte_Downstream_Identifier
    end

    def byte_upstream_identifier
      Brazen_::Collection::Byte_Upstream_Identifier
    end

    def cfg
      Brazen_::Collection_Adapters::Git_Config
    end

    def collections
      Brazen_::Collection_Adapters
    end

    def expression_agent_library
      Brazen_::API::Expression_Agent__::LIB
    end

    def event
      Callback_::Event
    end

    def lib_
      LIB_
    end

    def members
      singleton_class.instance_methods( false ) - [ :members ]
    end

    def name_library
      NAME
    end

    def name_function
      @nf ||= Callback_::Name.via_module self
    end

    def node_identifier
      Brazen_::Kernel_::Node_Identifier__
    end

    def properties_stack
      Brazen_::Entity::Properties_Stack__
    end

    def test_support
      require_relative 'test/test-support'
      Brazen_::TestSupport
    end
  end  # >>

  module Actor_
    class << self
      def [] cls, * x_a
        Callback_::Actor.via_client_and_iambic cls, x_a
        cls.extend Brazen_.name_library.name_function_proprietor_methods
        # cls.include self
        Brazen_.event.selective_builder_sender_receiver cls
        NIL_
      end
      alias_method :call, :[]
    end  # >>
  end

  Autoloader_ = Callback_::Autoloader

  module Collection_Adapters

    class << self
      def name_function
        Models_::Collection.name_function  # hack city
      end
    end  # >>

    Autoloader_[ self, :boxxy ]
  end

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Callback_::Memoize

    Basic = sidesys[ :Basic ]

    NLP_EN_methods = -> do
      HL__[].expression_agent.NLP_EN_methods
    end

    HL__ = sidesys[ :Headless ]

    Hu___ = sidesys[ :Human ]

    IO_lib = -> do
      System_lib__[]::IO
    end

    JSON = stdlib[ :JSON ]

    Module_lib = -> do
      Basic[]::Module
    end

    Mutable_iambic_scanner = -> do
      Brazen_::Entity.mutable_polymorphic_stream
    end

    N_lines = -> do
      Brazen_.event::N_Lines
    end

    Net_HTTP = _memoize do
      require 'net/http'
      ::Net::HTTP
    end

    NLP = -> do
      Hu___[]::NLP
    end

    Old_CLI_lib = -> do
      HL__[]::CLI
    end

    Open3 = stdlib[ :Open3 ]

    Parse_lib = sidesys[ :Parse ]

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Snag_ = sidesys[ :Snag ]

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    String_IO = stdlib[ :StringIO ]

    String_scanner = _memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    Two_streams = -> do
      System[].IO.some_two_IOs
    end
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  ACTIONS_CONST_ = :Actions
  Brazen_ = self
  Box_ = Callback_::Box
  CONTINUE_ = nil
  CONST_SEP_ = Callback_.const_sep
  DASH_ = '-'.freeze
  DONE_ = true
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  LIB_ = Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  NAME_ = :name
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  PROCEDE_ = true
  Autoloader_[ Proxies_ = ::Module.new ]
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false
  stowaway :TestSupport, 'test/test-support'
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
