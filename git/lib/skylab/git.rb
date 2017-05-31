require 'skylab/common'

module Skylab::Git

  def self.describe_into_under y, _
    y << "assorted novelties for manipulating reository content (versioned or not)"
  end

  Common_ = ::Skylab::Common

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  lazily :CLI do

    class CLI < Home_.lib_.brazen::CLI

      expose_executables_with_prefix 'tmx-git-'

      def back_kernel
        Home_::API.application_kernel_
      end

      self
    end
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

  Home_ = self

  class << Home_

    def check_SCM * a
      if a.length.zero?
        Home_::Check
      else
        Home_::Check.line_oriented_via_arguments__ a
      end
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x then instance_variable_set ivar, x ; true else x end
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

    def HELLO_INVOCATION  # type-check - temporary during development :/
      NIL
    end
  end

  # ==

  Lazy_ = Common_::Lazy

  Operator_branch___ = Lazy_.call do

    MTk_::ModelCentricOperatorBranch.define do |o|  # (find the implementation in [pl])

      # (every imaginable detail of the below is explained at [#pl-011.1])

      o.add_actions_module_path_tail "stow/actions"  # all actions in corefile

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

    def system_conduit
      Home_.lib_.open_3
    end

    def listener
      @argument_scanner.listener
    end

    attr_reader(
      :argument_scanner,
    )
  end

  # ==

  Require_brazen_ = Lazy_.call do
    self._ITS_GONE__pete_tong__
    Brazen_ = ::Skylab::Brazen
  end

  Process_ = -> * five do
    Home_.lib_.basic::Process.via_five( * five )
  end

  Require_microservice_toolkit___ = Lazy_.call do
    MTk_ = Zerk_lib_[]::MicroserviceToolkit ; nil
  end

  Zerk_lib_ = Lazy_.call do
    Autoloader_.require_sidesystem :Zerk
  end

  # ==

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    Shellwords = -> do
      require 'shellwords'
      ::Shellwords
    end

    System = -> do
      System_lib[].services
    end

    ACS = sidesys[ :Arc ]
    Basic = sidesys[ :Basic ]
    Brazen_NOUVEAU = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Git_viz = sidesys[ :GitViz ]
    Open_3 = stdlib[ :Open3 ]
    Plugin = sidesys[ :Plugin ]
    System_lib = sidesys[ :System ]
    Time = Lazy_.call { require 'time' ; ::Time }  # for tests only
    # Zerk = sidesys[ :Zerk ]  use Zerk_lib_[]
  end

  # ==

  module Library_

    stdlib, = Autoloader_.at :require_stdlib

    o = { }
    o[ :FileUtils ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end

  # ==

  ACHIEVED_ = true
  DASH_ = '-'.freeze
  DOT_ = '.'
  EMPTY_A_ = []
  EMPTY_P_ = -> { NIL_ }
  GIT_EXE_ = 'git'
  KEEP_PARSING_ = true
  NIL_ = nil
  NOTHING_ = nil
  ProcLike_ = Common_::ProcLike
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
