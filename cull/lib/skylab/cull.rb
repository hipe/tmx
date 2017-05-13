require 'skylab/common'

module Skylab::Cull

  def self.describe_into_under y, _expag
    y << "reduce a search space by a criteria - i.e helps make decisions"
  end

  Common_ = ::Skylab::Common

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  lazily :CLI do
    ::Class.new Brazen_::CLI
  end

  API = ::Module.new
  class << API

    def call * a, & p  # #cp 1 of N
      bc = invocation_via_argument_array( a, & p ).to_bound_call_of_operator
      bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
    end

    def invocation_via_argument_array a, & p
      Require_microservice_toolkit___[]
      _as = MTk_::API_ArgumentScanner.new a, & p
      MicroserviceInvocation___.new InvocationResources___.new _as
    end
  end  # >>

  class << self
    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  module Models_

    # Autoloader_[ self, :boxxy ]
    Autoloader_[ self ]
  end

  Models_::Ping = -> some_word, stackish, & oes_p do

    # (for a class-based ping, see #spot1-1)

    oes_p.call :info, :expression, :ping do |y|
      buffer = "the '"
      buffer << stackish.invocation_stack_top_name_symbol.id2name
      buffer << "' action of "
      buffer << stackish.microservice_invocation.app_name_string
      buffer << " says #{ highlight "hello" }!"
      y << buffer
    end

    :hello_from_cull
  end

  Lazy_ = Common_::Lazy

  Common_entity_ = -> * x_a, & x_p do
    self._THIS_IS_GONE__pete_tong__

    Home_.lib_.fields::Entity::Apply_entity[ Brazen_::Modelesque::Entity, x_a, & x_p ]
  end

  # == METHODS

  HARD_CALL_METHOD_ = -> * values, arg_box, & oes_p do  # 1x

    st = const_get( :ATTRIBUTES, false ).to_defined_attribute_stream

    o = begin_session__( & oes_p )

    values.length.times do |d|
      _atr = st.gets
      o.instance_variable_set _atr.as_ivar, values.fetch( d )
    end

    begin
      atr = st.gets
      atr or break
      _ivar = :"#{ atr.as_ivar }_arg"
      _x = arg_box.fetch atr.name_symbol
      o.instance_variable_set _ivar, _x
      redo
    end while nil

    o.execute
  end

  VALUE_BOX_EXPLODER_CALL_METHOD_ = -> value_box, & oes_p do  # 1x

    # for every defined attribute (only the names matter), read the value
    # from the value box and write it to the session as an ivar. then execute.

    o = begin_session__( & oes_p )

    st = const_get( :ATTRIBUTES, false ).to_defined_attribute_stream

    begin
      atr = st.gets
      atr or break
      o.instance_variable_set atr.as_ivar, value_box[ atr.name_symbol ]
      redo
    end while nil

    o.execute
  end

  FUNCTION_NAME_CONVENTION_ = -> name do
    s = name.as_lowercase_with_underscores_string
    s[ 0 ] = s[ 0 ].upcase
    s.intern
  end

  # ==

  module CommonActionMethods_

    def init_action_ ms_invo
      @_microservice_invocation_ = ms_invo ; nil
    end

    def _listener_
      @_microservice_invocation_.invocation_resources.listener
    end

    attr_reader(
      :_microservice_invocation_,
    )
  end

  # ==

  class MicroserviceInvocation___

    def initialize invo_rsx
      @invocation_resources = invo_rsx
    end

    def to_bound_call_of_operator
      MTk_::BoundCall_of_Operation_via[ self, Operator_branch___[] ]
    end

    attr_reader(
      :invocation_resources,
    )

    def app_name_string  # for ping and maybe nothing else
      @___ANS ||= Common_::Name.via_module( Home_ ).as_human
    end

    def HELLO_INVOCATION  # type-check - temporary during development :/
      NIL
    end
  end

  # ==

  Operator_branch___ = Lazy_.call do

    MTk_::ModelCentricOperatorBranch.define do |o|  # (find the implementation in [pl])

      # (every imaginable detail of the below is explained at [#pl-011.1])

      o.add_model_modules_glob '*', 'actions'  # GLOB_STAR_

      # o.add_actions_module_path_tail "ping/actions"
      o.add_actions_module_path_tail "ping"

      o.models_branch_module = Home_::Models_

      o.bound_call_via_action_with_definition_by = -> act do
        MTk_::BoundCall_of_Operation_with_Definition[ act ]
      end

      o.filesystem = ::Dir
    end
  end

  # ==

  class InvocationResources___

    def initialize as
      @argument_scanner = as
    end

    if false
    def filesystem
      Home_.lib_.system.filesystem
    end

    def system_conduit
      Home_.lib_.open_3
    end
    end

    def listener
      @argument_scanner.listener
    end

    attr_reader(
      :argument_scanner,
    )
  end

  # ==

  module Special_boxxy_

    # memoize special index information about its constituency *into* the
    # module for use in unmarshaling

    class << self
      def call mod
         Autoloader_[ mod, :boxxy ]
         mod.extend self ; nil
      end
      alias_method :[], :call
    end  # >>

    def to_special_boxxy_item_name_stream__
      _a = ( @___special_index ||= __build_item_index_array )
      Common_::Stream.via_nonsparse_array _a
    end

    def __build_item_index_array

      _hi = constants  # assume these are boxxy (some or all are inferred)

      _hey = _hi.map do |const|
        Common_::Name.via_const_symbol const
      end

      _hey.freeze
    end

    define_method :boxxy_const_guess_via_name, FUNCTION_NAME_CONVENTION_
  end

  # == FUNCTIONS

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  Build_not_OK_event_ = -> * i_a, & msg_p do
    i_a.push :ok, false
    Common_::Event.inline_via_iambic_and_any_message_proc_to_be_defaulted i_a, msg_p
  end

  Build_event_ = -> * i_a, & msg_p do
    Common_::Event.inline_via_iambic_and_any_message_proc_to_be_defaulted i_a, msg_p
  end

  # ==

  Require_microservice_toolkit___ = Lazy_.call do
    MTk_ = Zerk_lib_[]::MicroserviceToolkit ; nil
  end

  Zerk_lib_ = Lazy_.call do
    Autoloader_.require_sidesystem :Zerk
  end

  # ==

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Load_JSON_lib = -> do
      require 'json'
      nil
    end

    String_scanner = -> x do
      require 'strscan'
      ::StringScanner.new x
    end

    System = -> do
      System_lib[].services
    end

    Basic = sidesys[ :Basic ]
    # = sidesys[ :Brazen ]  # for [sl]
    Fields = sidesys[ :Fields ]
    System_lib = sidesys[ :System ]
    # = sidesys[ :Zerk ]  # for [sl]
  end

  # ==

  ACHIEVED_ = true
  Home_ = self
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  KEEP_PARSING_ = true
  NIL_ = nil
  UNABLE_ = false
end
