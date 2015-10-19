require 'skylab/callback'

module Skylab::Brazen

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Home_::Kernel.new Home_
    end )

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

    def expression_agent_library
      Home_::API::Expression_Agent__::LIB
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

    def test_support  # :+[#ts-035]

      if ! Home_.const_defined? :TestSupport, false
        require_relative '../../test/test-support'
      end

      Home_::TestSupport
    end
  end  # >>

  Actor_ = -> cls, * i_a, & x_p do

    # buffer ourselves from our past and our future

    Callback_::Actor.edit_module_via_mutable_iambic cls, i_a, & x_p
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

      bx ||= MONADIC_EMPTINESS_

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

  class Interface_Tree_Node_  # ([#098] tracks client candidates)

    # base class for nodes in the inteface tree (currently model, action).
    # (the categories are pursuant to [#024] top)

    # ~ actionability - identity in & navigation of the interface tree

    def self.adapter_class_for _  # moda. specific hook for hax
      NIL_
    end

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
          # ivar name is :+#public-API
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

    ## ~~ readers (narrated)

    def to_qualified_knownness_stream_

      foz = formal_properties

      if foz

        sym_a = foz.get_names
        sym_a.sort!

        Callback_::Stream.via_nonsparse_array( sym_a ).map_by do | sym |

          qualified_knownness sym
        end
      else
        Callback_::Stream.the_empty_stream
      end
    end

    def formal_properties
      self.class.properties
    end

    class << self

      def properties
        NIL_  # by default you have none, be you action or model
      end
    end

    def knownness_via_property_ prp

      knownness prp.name_symbol
    end

    def qualified_knownness sym

      had = true
      x = as_entity_actual_property_box_.fetch sym do
        had = false
      end

      Callback_::Qualified_Knownness.via_value_and_had_and_model(
        x, had, formal_properties.fetch( sym ) )
    end

    def knownness sym

      had = true
      x = as_entity_actual_property_box_.fetch sym do
        had = false
      end

      if had
        Callback_::Known.new_known x
      else
        Callback_::Known::UNKNOWN
      end
    end

    ## ~~ writers ( & related )

    define_method :process_polymorphic_stream_fully, PPSF_METHOD_
    ppsp = :process_polymorphic_stream_passively
    define_method ppsp, PPSP_METHOD_
    private ppsp

    def receive_missing_required_properties_event ev

      # [#001]:#stowaway-1 explains why this method is here

      raise ev.to_exception
    end

    ## ~~ editing your node's set of *formal* properties

    class << self

      def edit_entity_class * x_a, & edit_p

        # (block is used in one place in [ts] at writing)

        _what = entity_enhancement_module

        o = Home_::Entity::Session.new
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

  KNOWNNESS_VIA_IVAR_METHOD_ = -> prp do

    ivar = prp.ivar

    if instance_variable_defined? ivar

      Callback_::Known.new_known instance_variable_get ivar
    else
      Callback_::Known::UNKNOWN
      # raise ::NameError, __say_no_ivar( ivar )
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
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]

    IO_lib = -> do
      System_lib__[]::IO
    end

    JSON = stdlib[ :JSON ]

    Module_lib = -> do
      Basic[]::Module
    end

    Mutable_iambic_scanner = -> do
      Home_::Entity.mutable_polymorphic_stream
    end

    N_lines = -> do
      Callback_::Event::N_Lines
    end

    Net_HTTP = _memoize do
      require 'net/http'
      ::Net::HTTP
    end

    Old_CLI_lib = -> do
      self._WHERE
    end

    Open_3 = stdlib[ :Open3 ]

    Parse = sidesys[ :Parse ]

    Plugin = sidesys[ :Plugin ]

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

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  ACTIONS_CONST = :Actions
  Home_ = self
  Box_ = Callback_::Box
  Autoloader_[ Concerns_ = ::Module.new ]
  CONTINUE_ = nil
  CONST_SEP_ = Callback_.const_sep
  DASH_ = '-'.freeze
  DONE_ = true
  DOT_DOT_ = '..'
  EMPTY_A_ = [].freeze
  EMPTY_H_ = {}.freeze
  EMPTY_P_ = -> { NIL_ }
  EMPTY_S_ = ''.freeze
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  LIB_ = Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  MONADIC_EMPTINESS_ = -> _ { NIL_ }
  NAME_SYMBOL = :name
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false
  stowaway :TestSupport, 'test/test-support'
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
