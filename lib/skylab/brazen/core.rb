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

    def lib_
      LIB_
    end

    def members
      singleton_class.instance_methods( false ) - [ :members ]
    end

    def name_library
      Concerns_::Name
    end

    def name_function
      @nf ||= Callback_::Name.via_module self
    end

    def node_identifier
      Concerns_::Identifier
    end

    def test_support
      require_relative 'test/test-support'
      Brazen_::TestSupport
    end
  end  # >>

  Actor_ = -> cls, * i_a, & x_p do

    # buffer ourselves from our past and our future

    Callback_::Actor.via_client_and_iambic cls, i_a, & x_p
  end

  PPSF_METHOD_ = -> st, & x_p do  # "process polymorphic stream fully"

    kp = process_polymorphic_stream_passively st, & x_p

    if kp
      if st.unparsed_exists

        ev = Callback_::Actor::Methodic::Build_extra_values_event[
          [ st.current_token ] ]

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

      bx ||= EMPTY_P_

      instance_variable_set :@polymorphic_upstream_, st

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

      remove_instance_variable :@polymorphic_upstream_
    end
    kp
  end

  class Interface_Tree_Node_

    # base class for nodes in the inteface tree (currently model, action).
    # (the categories are pursuant to [#024] top)

    # ~ actionability - identity in & navigation of the interface tree

    def to_kernel
      @kernel
    end

    # ~ description & inflection

    class << self
      attr_accessor :description_block
    end

    def has_description
      ! self.class.description_block.nil?
    end

    def under_expression_agent_get_N_desc_lines expag, d=nil  # assume has

      LIB_.N_lines[ [], d, [ self.class.description_block ], expag ]
    end

    # ~ name

    class << self

      def name_function
        @name_function ||= Concerns_::Name::Build_name_function[ self ]
          # (ivar name is :+#public-API )
      end

      def name_function_class
        Concerns_::Name
      end
    end

    def name
      self.class.name_function
    end

    # ~ placement & visibility

    class << self
      attr_accessor :after_name_symbol
    end

    def after_name_symbol
      self.class.after_name_symbol
    end

    def is_visible
      true
    end

    # ~ preconditions

    class << self

      attr_accessor :precondition_controller_i_a_

      def preconditions
        @__did_resolve_pcia ||= resolve_precondition_controller_identifer_array
        @preconditions
      end
    end

    # ~ properties ( these :#hook-out's MUST get overridden by property lib )

    class << self

      def properties
        NIL_  # by default you have none, be you action or model
      end
    end

    def formal_properties
      self.class.properties
    end

    define_method :process_polymorphic_stream_fully, PPSF_METHOD_
    ppsp = :process_polymorphic_stream_passively
    define_method ppsp, PPSP_METHOD_
    private ppsp

    def trio sym  # may soften..

      _prp = formal_properties.fetch sym

      had = true
      x = actual_property_box.fetch sym do
        had = false
        nil
      end

      Callback_::Trio.via_value_and_had_and_property x, had, _prp
    end

    def receive_missing_required_properties_event ev

      # [#001]:#stowaway-1 explains why this method is here

      raise ev.to_exception
    end

    ## ~~ editing your node's set of *formal* properties

    class << self

      def edit_entity_class * x_a, & edit_p

        if edit_p
          $stderr.puts "\n\n\n  #{ '>' * 30 }\n   USING CLASSIC STYLE ON A NEW THING: #{ self }\n\n\n"
        end

        _what = entity_enhancement_module

        o = Brazen_::Entity::Session.new
        o.arglist = x_a
        o.client = self
        o.extmod = _what
        o.block = edit_p
        o.execute
      end
    end

    # ~ event receiving & sending

    private def maybe_send_event * i_a, & ev_p

      handle_event_selectively[ * i_a, & ev_p ]
    end

    def handle_event_selectively  # idiomatic accessor for this, :+#public-API

      @on_event_selectively
    end
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
      Callback_::Event::N_Lines
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
  Autoloader_[ Concerns_ = ::Module.new ]
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
  NAME_SYMBOL = :name
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
