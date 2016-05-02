require 'skylab/callback'

module Skylab::Brazen

  Callback_ = ::Skylab::Callback

  class << self

    def actionesque_defaults
      Home_::Nodesque::Methods::Actionesque_Defaults
    end

    define_method :application_kernel_, ( Callback_.memoize do
      Home_::Kernel.new Home_
    end )

    def branchesque_defaults
      Home_::Nodesque::Methods::Branchesque_Defaults
    end

    def byte_downstream_identifier
      Home_::Collection::Byte_Downstream_Identifier
    end

    def byte_upstream_identifier
      Home_::Collection::Byte_Upstream_Identifier
    end

    def cfg
      Home_::Collection_Adapters::Git_Config
    end

    def collections
      Home_::Collection_Adapters
    end

    def describe_into_under y, expag

      y << "the prototype [br] app (sidelined for now as a real app)"
    end

    def event const
      Home_.lib_.the_ACS_lib::Events.const_get const, false
    end

    def expression_agent_library
      Home_::API::Expression_Agent__::LIB
    end

    def event_class const
      Home_::Actionesque::Factory::Events.const_get const, false
    end

    def lib_
      LIB_
    end

    def members
      singleton_class.instance_methods( false ) - [ :members ]
    end

    def name_library
      Home_::Nodesque::Name
    end

    def name_function
      @nf ||= Callback_::Name.via_module self
    end

    def node_identifier
      Home_::Nodesque::Identifier
    end

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport, false
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end
  end  # >>

  PPSF_METHOD_ = -> st, & x_p do  # "process polymorphic stream fully"

    kp = process_polymorphic_stream_passively st, & x_p

    if kp

      if st.unparsed_exists

        ev = Home_.lib_.fields::Events::Extra.via_strange st.current_token

        if respond_to? :receive_extra_values_event
          receive_extra_values_event ev
        else
          raise ev.to_exception
        end
      else
        kp
      end
    else
      kp
    end
  end

  PPSP_METHOD_ = -> st, & x_p do  # "process polymorphic stream passively"  make it private

    bx = formal_properties
    kp = KEEP_PARSING_

    if st.unparsed_exists

      bx ||= MONADIC_EMPTINESS_

      instance_variable_set :@_polymorphic_upstream_, st

      begin

        k = st.current_token

        prp = bx[ k ]
        prp or break

        st.advance_one

        m = prp.custom_polymorphic_writer_method_name

        kp = if m
          send m
        else
          receive_polymorphic_property prp, & x_p
        end

        kp or break

        if st.unparsed_exists
          redo
        end
        break
      end while nil

      remove_instance_variable :@_polymorphic_upstream_
    end
    kp
  end

  Lazy_ = Callback_::Lazy

  Require_fields_lib_ = Lazy_.call do  # ..
    Field_ = Home_.lib_.fields
    NIL_
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

  module Modelesque

    def self.entity * a, & edit_p
      Home_::Entity::Apply_entity[ self::Entity, a, & edit_p ]
    end

    Autoloader_[ self ]
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  # (was N_Lines_)

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Callback_::Lazy

    The_ACS_lib = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]

    IO_lib = -> do
      System_lib[]::IO
    end

    JSON = stdlib[ :JSON ]

    Module_lib = -> do
      Basic[]::Module
    end

    Mutable_iambic_scanner = -> do
      Home_::Entity.mutable_polymorphic_stream
    end

    Net_HTTP = _memoize do
      require 'net/http'
      ::Net::HTTP
    end

    Open_3 = stdlib[ :Open3 ]

    Parse = sidesys[ :Parse ]

    Plugin = sidesys[ :Plugin ]

    Stdlib_option_parser = _memoize do
      require 'optparse'
      ::OptionParser
    end

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    String_IO = stdlib[ :StringIO ]

    String_scanner = _memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    Two_streams = -> do
      System[].IO.some_two_IOs
    end

    Zerk = sidesys[ :Zerk ]  # for testing only
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  ACTIONS_CONST = :Actions
  Box_ = Callback_::Box
  CONST_SEP_ = Callback_.const_sep
  DASH_ = '-'.freeze
  DOT_DOT_ = '..'
  EMPTY_A_ = [].freeze
  EMPTY_H_ = {}.freeze
  EMPTY_P_ = -> { NIL_ }
  EMPTY_S_ = ''.freeze
  Home_ = self
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  LIB_ = Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  MONADIC_EMPTINESS_ = -> _ { NIL_ }
  NAME_SYMBOL = :name
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false
  stowaway :TestSupport, 'test/test-support'
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
  UNRELIABLE_ = false
end
