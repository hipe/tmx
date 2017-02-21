require 'skylab/common'

module Skylab::Snag

  def self.describe_into_under y, _
    y << "exciting experiments in issue tracking simplification"
  end

  # ==

  module API

    class << self

      def call * a, & p
        _microservice_invocation( p, a ).execute
      end

      def invocation_via_argument_array a, & p
        _microservice_invocation p, a
      end

      def _microservice_invocation p, a
        Require_microservice_toolkit__[]
        _as = MTk_::API_ArgumentScanner.new a, & p
        MicroserviceInvocation__.new InvocationResources___.new _as
      end
    end  # >>
  end

  # == forward-declarations

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  NOTHING_ = nil
  Lazy_ = Common_::Lazy

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x  do
    if x ; instance_variable_set ivar, x ; ACHIEVED_ ; else x end
  end

  # ==

  class MicroserviceInvocation__

    # (a pioneer. will probably move up)

    def initialize invo_rsx
      @_invocation_resources = invo_rsx
    end

    def execute
      bc = __flush_to_bound_call_of_operator
      bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
    end

    def __flush_to_bound_call_of_operator  # (near `to_bound_call_of_operator`)

      @omni = MTk_::ParseArguments_via_FeaturesInjections.define do |o|

        o.argument_scanner = @_invocation_resources.argument_scanner

        o.add_operators_injection_by do |inj|

          inj.operators = @_invocation_resources.microservice_operator_branch_
          inj.injector = :_no_injector_for_now_from_SN_
        end
      end

      if _store :@__found_operator, @omni.parse_operator
        __bound_call_of_operator_via_operator_found
      end
    end

    def __bound_call_of_operator_via_operator_found

      _lt = remove_instance_variable( :@__found_operator ).mixed_business_value
      _lt.bound_call_of_operator_via_invocation_resouces @_invocation_resources
    end

    define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
  end

  # ==

  class InvocationResources___  # :#here, #testpoint

    def initialize as
      @argument_scanner = as
    end

    # (hard-coded per (what we used to call) "silo" - it has been un-abstracted)

    def criteria_resources
      @___criteria_resources ||= __criteria_resources
    end

    def __criteria_resources
      Models_::Criteria::CriteriaResources.via_invocation_resources__ self
    end

    def node_collection_filesystem_adapter
      @___NC_FSA ||= __node_collection_filesystem_adapter
    end

    def __node_collection_filesystem_adapter
      Models_::NodeCollection::FilesystemAdapter.new _filesystem
    end

    def microservice_operator_branch_
      Operator_branch___[]
    end

    def application_moniker
      "snaggolio"
    end

    def _filesystem
      _ = Home_.lib_.system.filesystem
      _  # hi. #todo
    end

    def listener
      @argument_scanner.listener
    end

    attr_reader :argument_scanner
  end

  # ==

  Operator_branch___ = Lazy_.call do

    Require_microservice_toolkit__[]  # necessary only from some tests

    MTk_::ModelCentricOperatorBranch.define do |o|

      # (every imaginable detail of the below is explained at [#pl-011.1])

      same = 'actions'

      o.add_actions_module_path_tail ::File.join 'ping', same

      o.add_actions_modules_glob ::File.join GLOB_STAR_, 'actions{,.rb}'

      o.add_actions_module_path_tail ::File.join 'criteria', same

      o.models_branch_module = Models_

      o.bound_call_via_action_with_definition_by = -> act do
        BoundCall_via_Action_with_Definition___[ act ]
      end

      o.filesystem = ::Dir
    end
  end

  # ==

  class BoundCall_via_Action_with_Definition___ < Common_::Monadic

    # (will likely move up to a toolkit)

    def initialize act
      @action = act
    end

    def execute
      if __normal
        Common_::BoundCall.by( & @action.method( :execute ) )
      end
    end

    def __normal
      _st = __formal_parameter_stream
      _ok = MTk_::Normalize.call_by do |o|
        o.entity = @action
        o.formal_attribute_stream = _st
      end
      _ok  # hi. #todo
    end

    def __formal_parameter_stream
      Action_grammar___[].stream_via_array( @action.definition ).map_reduce_by do |qual_item|
        if :_parameter_SN_ == qual_item.injection_identifier
          qual_item.item
        end
      end
    end
  end

  # ==

  Action_grammar___ = Lazy_.call do

    # for now, we built our entity/action grammar here ourself.
    # one day maybe this will become a cleaner part of a toolkit

    # ..

    lib = Home_.lib_
    Fields_ = lib.fields
    Parse_ = lib.parse_lib

    # ..

    _param_gi = Fields_::Attributes::
      DefinedAttribute::EntityKillerParameter.grammatical_injection

    _g = Parse_::IambicGrammar.define do |o|

      o.add_grammatical_injection :_branch_desc_SN_, BRANCH_DESCRIPTION___

      o.add_grammatical_injection :_parameter_SN_, _param_gi
    end

    _g  # hi. #todo
  end

  module BRANCH_DESCRIPTION___ ; class << self

    def is_keyword k
      :branch_description == k
    end

    def gets_one_item_via_scanner scn
      scn.advance_one ; scn.gets_one
    end
  end ; end

  # ==

  module ActionRelatedMethods_

    def init_action_ rsx  # resources, #here
      @_argument_scanner_ = rsx.argument_scanner
    end

    define_method :_store_, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

    def _write_ k, x
      instance_variable_set :"@#{ k }", x
    end

    def _read_ k
      ivar = :"@#{ k }"
      if instance_variable_defined? ivar
        instance_variable_get ivar
      end
    end

    def _listener_
      @_argument_scanner_.listener
    end

    attr_reader :_argument_scanner_
  end

  # == ping is a stowaway

  module Models_

    class Ping

      def initialize
        o = yield
        @__application_moniker = o.application_moniker
        @__listener = o.listener
      end

      def execute
        s = @__application_moniker
        @__listener.call :info, :expression, :ping do |y|
          y << "#{ s } says #{ em 'hello!' }"
        end
        :hello_from_snag
      end

      Actions = NOTHING_
      ExpressionAdapters = NOTHING_
    end

    Autoloader_[ self ]
  end

  # == support

  module Expression_Methods_

    def description_under expag
      y = expag.new_expression_context
      express_into_under y, expag
      y
    end

    def express_into_under y, expag

      sym = expag.modality_const
      if sym
        expad_for_( sym ).express_into_under_of_ y, expag, self
      else
        express_into_ y
      end
    end

    def express_N_units_into_under d, y, expag

      sym = expag.modality_const
      if sym
        expad_for_( sym ).express_N_units_into_under_of_ d, y, expag, self
      else
        express_N_units_into_under_agnostic_ d, y, exag
      end
    end

    def expad_for_ sym

      self.class::ExpressionAdapters.const_get sym, false
    end
  end

  # ==

  INTERPRET_OUT_OF_UNDER_METHOD_ = -> x, moda, & oes_p do

    self::ExpressionAdapters.const_get( moda.intern, false ).
      const_get( :Interpret, false )[ x, moda, & oes_p ]
  end

  # ==

  Require_microservice_toolkit__ = Lazy_.call do
    MTk_ = Zerk_lib_[]::MicroserviceToolkit ; nil
  end

  ACS_ = Lazy_.call do
    Home_.lib_.autonomous_component_system
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Zerk_lib_ = Lazy_.call do
    x = Home_.lib_.zerk
    Zerk_ = x
    x
  end

  class << self

    def lib_
      @___lib ||=  Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end

    def _NO_MORE_COMMON_ACTION
      _hi = caller_locations(1,1)[0].path
      $stderr.puts "nerp: #{ _hi }"
      exit 0
    end
  end  # >>

  # ==

  # --

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    A_short_length = -> do
      Basic[]::String.a_reasonably_short_length_for_a_string
    end

    CLI_legacy_DSL = -> mod do
      Porcelain__[]::Legacy::DSL[ mod ]
    end

    EN_mini = -> do
      NLP[]::EN
    end

    Entity = -> do
      Fields[]::Entity
    end

    Event = -> do
      Brazen[].event
    end

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    NLP = -> do
      Hu__[]::NLP
    end

    Patch_lib = -> do
      System[].patch
    end

    Strange = -> * x_a do
      Basic[]::String.via_mixed.call_via_arglist x_a
    end

    String_lib = -> do
      Basic[]::String
    end

    System = -> do
      System_lib[].services
    end

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Hu__ = sidesys[ :Human ]
    Parse_lib = sidesys[ :Parse ]
    System_lib = sidesys[ :System ]
    Zerk = sidesys[ :Zerk ]  # 2x only, at writing
  end

  module Library_

    stdlib = Autoloader_.method :require_stdlib

    o = { }
    o[ :DateTime ] = stdlib
    o[ :FileUtils ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Shellwords ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do | sym |
      p = o[ sym ]
      if p
        const_set sym, p[ sym ]
      else
        super
      end
    end
  end

  # --

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_= true
  Bsc__ = Autoloader_.build_require_sidesystem_proc :Basic
  Bzn__ = Autoloader_.build_require_sidesystem_proc :Brazen
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''
  GLOB_STAR_ = '*'
  stowaway :Library_, 'lib-'
  LINE_SEP_ = "\n"
  NIL_ = nil
  KEEP_PARSING_ = true
  MONADIC_EMPTINESS_ = -> _ { }
  NEUTRAL_ = nil
  NEWLINE_ = "\n"
  Home_ = self
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
# #tombstone-A: an old stubs action loader that required hand-written stubs
