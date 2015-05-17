require_relative '..'

require_relative '../callback/core'

module Skylab::Brazen

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Brazen_::Kernel.new Brazen_
    end )

    def bound_call * a, & x_p

      if a.length.nonzero? || x_p

        Callback_::Bound_Call.new( * a, & x_p )
      else

        Callback_::Bound_Call
      end
    end

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

  module NAME  # because its public interface is as a (library) singleton, not a module

    class << self

      def name_function_class
        Name_Function__
      end

      def name_function_proprietor_methods
        Name_Function_Proprietor_Methods__
      end

      def surrounding_module mod
        LIB_.module_lib.value_via_relative_path mod, DOT_DOT_
      end
    end  # >>

    DOT_DOT_ = '..'

    module Name_Function_Proprietor_Methods__  # infects upwards

      def name_function
        @name_function ||= bld_name_function  # :+#public-API (ivar name)
      end

      def full_name_function
        @fnf ||= bld_full_name_function
      end

    private

      def bld_full_name_function
        y = [ nf = name_function ]
        y.unshift nf while (( parent = nf.parent and nf = parent.name_function ))
        y.freeze
      end

      def bld_name_function
        stop_index = some_name_stop_index

        s_a = name.split CONST_SEP_
        i = s_a.pop.intern

        chain = LIB_.module_lib.chain_via_parts s_a
        d = chain.length

        while stop_index < ( d -= 1 )  # find nearest relevant parent
          pair = chain.fetch d
          mod = pair.value_x
          if ! mod.respond_to? :name_function
            TAXONOMIC_MODULE_RX__ =~ pair.name_symbol and next
            mod.extend Name_Function_Proprietor_Methods__
          end
          parent = mod
          break
        end
        name_function_class.new_via self, parent, i
      end

      def some_name_stop_index
        if const_defined? :NAME_STOP_INDEX
          self::NAME_STOP_INDEX
        else
          DEFAULT_STOP_INDEX__
        end
      end

      def name_function_class
        Name_Function__
      end

      DEFAULT_STOP_INDEX__ = 3  # skylab snag cli actions foo actions bar

      TAXONOMIC_MODULE_RX__ = /\AActions_{0,2}\z/  # meh / wee
    end

    class Name_Function__ < Callback_::Name

      class << self

        def new_via mod, parent, const

          new do
            init_via_three_ mod, parent, const
          end
        end
      end  # >>

      def init_via_three_ _mod, parent, const

        @parent = parent
        init_via_const_ const
      end

      attr_reader :parent
    end

    Autoloader_[ self ]
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

    Trio = -> do
      Basic[].trio
    end

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
