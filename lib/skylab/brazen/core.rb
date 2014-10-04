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

    def expression_agent_library
      API::Expression_Agent__::LIB
    end

    def event
      Brazen_::Entity.event
    end

    def model
      Brazen_::Model_::LIB
    end

    def model_entity * a, & p
      if a.length.nonzero? || p
        Brazen_::Model_::Entity[ * a, p ]
      else
        Brazen_::Model_::Entity
      end
    end

    def name_library
      NAME_LIBRARY__
    end

    def name_function
      @nf ||= Callback_::Name.from_module self
    end

    def node_identifier
      Brazen_::Kernel_::Node_Identifier__
    end
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module NAME_LIBRARY__

    class << self

      def name_function_class
        Name_Function__
      end

      def name_function_proprietor_methods
        Name_Function_Proprietor_Methods__
      end

      def surrounding_module mod
        name_s = mod.name
        name_s[ name_s.rindex( CONST_SEP__ ) .. -1 ] = EMPTY_S_
        name_s.split( CONST_SEP__ ).reduce( ::Object ) do |m, s|
          m.const_get s, false
        end
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

        stop_index = const_defined?( :NAME_STOP_INDEX ) ?
          self::NAME_STOP_INDEX : STOP_INDEX__

        s_a = name.split CONST_SEP__
        i = s_a.pop.intern
        x_a = ::Array.new s_a.length
        mod = ::Object
        s_a.each_with_index do |s, d|
          mod = mod.const_get s, false
          x_a[ d ] = mod
        end
        d = s_a.length

        while stop_index < ( d -= 1 )
          mod = x_a.fetch d
          if ! mod.respond_to? :name_function
            TAXONOMIC_MODULE_RX__ =~ s_a.fetch( d ) and next
            mod.extend Name_Function_Proprietor_Methods__
          end
          parent = mod
          break
        end
        name_function_class.new self, parent, i
      end

      def name_function_class
        Name_Function__
      end

      STOP_INDEX__ = 3  # skylab snag cli actions foo actions bar

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

    CONST_SEP__ = Callback_.const_sep
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

    Ellipsify = -> * x_a do
      Snag__[]::CLI.ellipsify.via_arglist x_a
    end

    EN_fun = -> do
      HL__[]::SubClient::EN_FUN
    end

    HL__ = sidesys[ :Headless ]

    Iambic_scanner = -> do
      Callback_.iambic_scanner
    end

    JSON = memoize[ -> { require 'json' ; ::JSON  } ]

    N_lines = -> do
      Event_[]::N_Lines
    end

    Net_HTTP = memoize[ -> { require 'net/http' ; ::Net::HTTP } ]

    NLP = -> do
      HL__[]::NLP
    end

    IO = -> do
      HL__[]::IO
    end

    Snag__ = sidesys[ :Snag ]

    Text = -> do
      Snag__[]::Text
    end

    Two_streams = -> do
      HL__[]::System::IO.some_two_IOs
    end
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Actor_ = -> cls, * x_a do
    Lib_::Snag__[]::Model_::Actor.via_client_and_iambic cls, x_a
    Event_[].sender cls ; nil
  end

  ACHEIVED_ = true
  Brazen_ = self

  Bound_Call__ = ::Struct.new :receiver, :method_name, :args
  class << Bound_Call__
    def the_empty_call
      @tec ||= new EMPTY_P_, :call
    end
    def via_value x
      new -> { x }, :call
    end
  end

  Box_ = Callback_::Box
  CONTINUE_ = nil
  DASH_ = '-'.freeze
  DONE_ = true
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  Entity_ = -> { Brazen_::Entity }
  Event_ = -> { Brazen_::Entity.event }
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  NAME_ = :name
  NILADIC_TRUTH_ = -> { true }
  PROCEDE_ = true
  Scan_ = -> { Callback_::Scan }
  SLASH_ = '/'.getbyte 0
  SPACE_ = ' '.freeze

  stowaway :TestSupport, 'test/test-support'

  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
