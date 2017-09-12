require 'skylab/common'

module Skylab::BeautySalon

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  class << self

    def describe_into_under y, _

      y << "an umbrella node for text-processing utilities -"
      y << "word wrap, search & replace, and comment processing functions"
    end

    define_method :application_kernel_, ( Common_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  lazily :CLI do

    Home_.lib_.brazen  # (touch early, make the rest more readable.)

    ::Skylab::Brazen::CLI::CLI_for_BeautySalon_PIONEER.begin_by do |o|

      o.operator_branch = Operator_branch_[]

      o.application_module = Home_
    end
  end

  if false  # #open [#043]
      expose_executables_with_prefix 'tmx-beauty-salon-'
  end

  module API

    class << self

      def call * a, & p
        invocation_via_argument_array( a, & p ).execute
      end

      def invocation_via_argument_array a, & p
        Require_user_interface_libs_[]
        _as = MTk_::API_ArgumentScanner.new a, & p
        MicroserviceInvocation___.new InvocationResources_.new _as
      end
    end  # >>
  end

  class MicroserviceInvocation___

    def initialize ir
      @invocation_resources = ir
    end

    def execute
      _ob = Operator_branch_[]
      oper = MTk_::ParseOperator_via[ self, _ob ]
      if oper
        _model_ref = oper.mixed_business_value
        bc = _model_ref.bound_call_of_operator_via_invocation_resouces @invocation_resources
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end

    attr_reader(
      :invocation_resources,
    )
  end

  Lazy_ = Common_::Lazy

  Operator_branch_ = Lazy_.call do

    Require_user_interface_libs_[]

    MTk_::ModelCentricOperatorBranch.define do |o|

      same = 'actions'

      _ = -> slug do
        o.add_actions_module_path_tail ::File.join( slug, same )
      end

      _[ 'ping' ]
        # (no actual actions directory or file so we need to declare it.)

      _[ 'crazy-town' ]
        # (same as ping)

      _[ 'deliterate' ]
        # (same as ping)

      _[ 'text' ]
        # (this one has a classical structure, but none of the others do)

      o.models_branch_module = Home_::Models_

      o.bound_call_when_operation_with_definition_by = -> oo do
        MTk_::BoundCall_of_Operation_with_Definition[ oo.operation ]
      end

      o.filesystem = ::Dir
    end
  end

  module CommonActionMethods_

    def _simplified_write_ x, k
      instance_variable_set :"@#{ k }", x
    end

    def _simplified_read_ k
      ivar = :"@#{ k }"
      if instance_variable_defined? ivar
        instance_variable_get ivar
      end
    end

    attr_reader(
      :_argument_scanner_,
      :_listener_,
    )
  end

  class InvocationResources_
    def initialize as
      @argument_scanner = as
      @filesystem = ::File  # maybe one day etc
    end
    def listener
      @argument_scanner.listener
    end
    attr_reader(
      :argument_scanner,
      :filesystem,
    )
  end

  Require_user_interface_libs_ = Lazy_.call do
    MTk_ = Home_.lib_.zerk::MicroserviceToolkit
  end

  DEFINITION_FOR_THE_METHOD_CALLED_EXCEPTION_ = -> e do
    @listener.call :error, :expression do |y|
      y << e.message
    end
    UNABLE_
  end

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # while #open [#now]
  module Models_

    Autoloader_[ self, :boxxy ]

    stowaway :Text, 'text/actions/wrap'
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Scanner_ = -> a do
    Common_::Scanner.via_array a
  end

  Require_brazen_LEGACY_ = Lazy_.call do
    Brazen_ = Home_.lib_.brazen
    NIL
  end

  Basic_ = -> do
    Home_.lib_.basic
  end

  module Lib_

    sidesys, gem = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc,
    )

    File_utils = Common_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    String_scanner = Common_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    Tree_lib = -> do
      ST__[]::Tree
    end

    Unparser = gem[ :Unparser ]

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Human = sidesys[ :Human ]
    Plugin = sidesys[ :Plugin ]
    ST__ = sidesys[ :SubTree ]
    System_lib = sidesys[ :System ]
    Zerk = sidesys[ :Zerk ]
  end

  ACHIEVED_ = true
  Home_ = self
  CONST_SEP_ = '::'.freeze
  DASH_ = '-'
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }          # for fun we track this
  NEWLINE_ = "\n"
  NIL_ = nil  # to emphasize its use
  NIL = nil  # #open [#sli-116.C]
  NOTHING_ = nil
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  STOP_PARSING_ = false
  THE_EMPTY_MODULE_ = ::Module.new.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
