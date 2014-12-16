require_relative '..'

require_relative '../callback/core'

module Skylab::Brazen

  class << self

    def bound_call *a
      if a.length.zero?
        Bound_Call__
      else
        Bound_Call__.new( *a )
      end
    end

    def cfg
      Brazen_::Data_Stores_::Git_Config
    end

    def expression_agent_library
      API::Expression_Agent__::LIB
    end

    def event
      Brazen_::Event__
    end

    def model
      Brazen_::Model_::LIB
    end

    def name_library
      NAME_LIBRARY_
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
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module NAME_LIBRARY_

    class << self

      def name_function_class
        Name_Function__
      end

      def name_function_proprietor_methods
        Name_Function_Proprietor_Methods__
      end

      def surrounding_module mod
        Brazen_::Lib_::Module_lib[].value_via_relative_path mod, '..'
      end
    end

    module Name_Function_Proprietor_Methods__  # infects upwards

      def name_function
        @nf ||= bld_name_function
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

        chain = Brazen_::Lib_::Module_lib[].chain_via_parts s_a
        d = chain.length

        while stop_index < ( d -= 1 )  # find nearest relevant parent
          pair = chain.fetch d
          mod = pair.value_x
          if ! mod.respond_to? :name_function
            TAXONOMIC_MODULE_RX__ =~ pair.name_i and next
            mod.extend Name_Function_Proprietor_Methods__
          end
          parent = mod
          break
        end
        name_function_class.new self, parent, i
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
        public :new
      end
      def initialize _mod, parent, const_i
        @parent = parent
        initialize_with_const_i const_i
      end
      attr_reader :parent
    end
  end

  module Data_Stores_
    class << self
      def name_function
        Models_::Datastore.name_function  # hack city
      end
    end
    Autoloader_[ self, :boxxy ]
  end

  module Lib_

    memoize = Callback_.memoize

    sidesys = Autoloader_.build_require_sidesystem_proc

    Bsc_ = sidesys[ :Basic ]

    Ellipsify = -> * x_a do
      Snag__[]::CLI.ellipsify.via_arglist x_a
    end

    NLP_EN_methods = -> do
      HL__[].expression_agent.NLP_EN_methods
    end

    HL__ = sidesys[ :Headless ]

    Iambic_scanner = -> do
      Callback_::Iambic_Stream
    end

    IO = -> do
      HL__[]::IO
    end

    JSON = memoize[ -> { require 'json' ; ::JSON  } ]

    Module_lib = -> do
      Bsc_[]::Module
    end

    Mutable_iambic_scanner = -> do
      Brazen_::Entity.mutable_iambic_stream
    end

    N_lines = -> do
      Brazen_.event::N_Lines
    end

    Net_HTTP = memoize[ -> { require 'net/http' ; ::Net::HTTP } ]

    NLP = -> do
      HL__[]::NLP
    end

    Old_CLI_lib = -> do
      HL__[]::CLI
    end

    Old_name_lib = -> do
      HL__[]::Name
    end

    Open3 = Callback_.memoize do
      require 'open3'
      ::Open3
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Snag__ = sidesys[ :Snag ]

    Strange = -> x do
      Autoloader_.require_sidesystem( :MetaHell ).strange x  # #todo
    end

    String_IO = -> do
      require 'stringio'
      ::StringIO
    end

    String_lib = -> do
      Bsc_[]::String
    end

    System = -> do
      HL__[].system
    end

    Trio = -> do
      Bsc_[].trio
    end

    Two_streams = -> do
      System[].IO.some_two_IOs
    end
  end

  LIB_ = ::Module.new  # stand-in
  class << LIB_
    def stream & p
      if block_given?
        Callback_::Scan.new( & p )
      else
        Callback_::Scan
      end
    end
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Actor_ = -> cls, * x_a do
    Lib_::Snag__[]::Model_::Actor.via_client_and_iambic cls, x_a
    Brazen_.event.selective_builder_sender_receiver cls ; nil
  end

  ACHIEVED_ = true
  Brazen_ = self

  Bound_Call__ = ::Struct.new :args, :receiver, :method_name do  # volatility order (subjective)

    class << self

      def build_via_arglist a
        if a.length.zero?
          self
        else
          new( * a )
        end
      end

      def the_empty_call
        @tec ||= new EMPTY_P_, :call
      end

      def via_value x
        new nil, -> { x }, :call
      end
    end
  end

  Box_ = Callback_::Box
  CONTINUE_ = nil
  CONST_SEP_ = Callback_.const_sep
  DASH_ = '-'.freeze
  DONE_ = true
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  Event_ = -> { Brazen_.event }
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  NAME_ = :name
  NEWLINE_ = "\n".freeze
  NILADIC_TRUTH_ = -> { true }
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false

  stowaway :TestSupport, 'test/test-support'

  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
