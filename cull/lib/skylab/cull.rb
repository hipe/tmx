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

    Autoloader_[ self, :boxxy ]  # because #spot2.1
  end

  Models_::Ping = -> some_word, stackish, & oes_p do

    # (for a class-based ping, see #spot1.1)

    oes_p.call :info, :expression, :ping do |y|
      buffer = "the '"
      buffer << stackish.invocation_stack_top_name_symbol.id2name
      buffer << "' action of "
      buffer << stackish.microservice_invocation.app_name_string
      buffer << " says #{ em "hello" }!"
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

  FUNCTION_NAME_CONVENTION_ = -> slug do
    s = slug.gsub DASH_, UNDERSCORE_
    s[ 0 ] = s[ 0 ].upcase
    s.intern
  end

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # ==

  module CommonActionMethods_

    def init_action_ ms_invo
      @_microservice_invocation_ = ms_invo ; nil
    end

    def _insert_via_index_and_association_symbol_ x, d, k

      # (stay close to `_insert_via_index_and_association_`)

      -1 == d || self._COVER_ME__no_ad_hoc_inserts_yet__
      ivar = :"@#{ k }"
      if instance_variable_defined? ivar
        a = instance_variable_get ivar
      else
        a = []
        instance_variable_set ivar, a
      end
      a.push x ; nil
    end

    def _simplified_write_ x, k
      instance_variable_set :"@#{ k }", x ; nil
    end

    def _simplified_read_ k
      ivar = :"@#{ k }"
      if instance_variable_defined? ivar
        instance_variable_get ivar
      end
    end

    def [] k  # ..
      instance_variable_get :"@#{ k }"
    end

    def _filesystem_
      _invocation_resources_.filesystem
    end

    def _listener_
      _invocation_resources_.listener
    end

    def _argument_scanner_
      _invocation_resources_.argument_scanner
    end

    def _invocation_resources_
      @_microservice_invocation_.invocation_resources
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

    def filesystem
      Home_.lib_.system.filesystem
    end

    if false
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
    class << self
      def call mod
        self._GONE__as_referenced_at_history__  # :#history-A.1
      end
      alias_method :[], :call
    end  # >>
  end

  # == FUNCTIONS

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

  NameValuePair_ = -> sym, x do
    Common_::QualifiedKnownKnown.via_value_and_symbol x, sym
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
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

    ACS = sidesys[ :Arc ]
    Basic = sidesys[ :Basic ]
    Brazen_NOUVEAU = sidesys[ :Brazen ]  # for [sl]
    Fields = sidesys[ :Fields ]
    Parse_lib = sidesys[ :Parse ]
    System_lib = sidesys[ :System ]
    # = sidesys[ :Zerk ]  # for [sl]
  end

  # ==

  ACHIEVED_ = true
  DASH_ = '-'
  Home_ = self
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
  NIL_AS_FAILURE_ = nil
  NOTHING_ = nil
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
# #history-A.1 (MUST be temporary) as referenced
