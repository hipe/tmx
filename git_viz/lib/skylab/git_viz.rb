require 'skylab/common'

module Skylab::GitViz

  class << self

    def describe_into_under y, _
      y << "awesome, simple tabular visualiztion of a repository over time"
    end

    def repository
      Home_::VCS_Adapters_::Git.repository
    end
  end  # >>

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  # --

  lazily :CLI do

    class CLI < Home_.lib_.brazen::CLI

      def initialize * a

        super
        receive_environment MONADIC_EMPTINESS_
          # (we don't remember why we wanted the above, but now it's exercize)
      end

      self
    end
  end

  module API

    class << self

      def call * x_a, & p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
  end

  class << self

    define_method :application_kernel_, ( Common_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  stowaway :Models_, 'models-/hist-tree'  # it's all here, for now

  Magnetics_::Relpath_via_Long_and_Short = -> long, short do

    d = short.length
    short == long[ 0, d ] or raise ::ArgumentError
    Path_looks_absolute_[ long ] or raise ::ArgumentError

    if short.length + 1 == d
      NIL_  # long path was just short path with trailing slash
    else
      long[ d + 1 .. -1 ]
    end
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Path_looks_absolute_ = -> path do
    Home_.lib_.system.path_looks_absolute path
  end

  Lazy_ = Common_::Lazy

  Require_things_ = Lazy_.call do
    Action_ = Home_.lib_.brazen::ActionToolkit
    NIL
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  # --

  ArgumentError = ::Class.new ::ArgumentError

  # --

  module Lib_  # :+[#ss-001]

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Common_::Memoize

    gem = stdlib

    # ~ universe modules, sidesystem facilities and short procs all as procs

    _Hu = nil

    Date_time = _memoize do
      require 'date'
      ::DateTime
    end

    Grit = _memoize do
      require 'grit'
      ::Grit
    end

    Local_normal_name_from_module = -> x do
      Common_::Name.via_module( x ).as_lowercase_with_underscores_symbol
    end

    MD5 = _memoize do
      require 'digest/md5'
      ::Digest::MD5
    end

    NLP = -> do
      _Hu[]::NLP
    end

    Mock_system_lib = -> do
      Home_::Test_Lib_
    end

    Option_parser = _memoize do
      require 'optparse'
      ::OptionParser
    end

    Power_scanner = -> * x_a do
      Common_::Scn.multi_step.via_iambic x_a
    end

    Shellwords = stdlib[ :Shellwords ]

    Some_stderr_IO = -> do
      System[].IO.some_stderr_IO
    end

    strange = Common_::Lazy.call do

      o = Basic[]::String.via_mixed.dup
      o.max_width = 120
      o.to_proc
    end

    Strange = -> x do
      strange[][ x ]
    end

    System = -> do
      System_lib[].services
    end

    Brazen = sidesys[ :Brazen ]
    Brazen_NOUVEAU = Brazen
    Basic = sidesys[ :Basic ]  # was wall
    Fields = sidesys[ :Fields ]
    Git = sidesys[ :Git ]
    JSON = stdlib[ :JSON ]
    if false  # i don't remember the below is but it ain't used #todo
    Listen = gem[ :Listen ]
    end
    _Hu = sidesys[ :Human ]
    Open3 = stdlib[ :Open3 ]
    Plugin = sidesys[ :Plugin ]
    Set = stdlib[ :Set ]
    System_lib = sidesys[ :System ]
    # ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]
  end

  # --

  ACHIEVED_ = true
  CONTINUE_ = nil
  DASH_ = '-'.freeze
  DOT_ = '.'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  Home_ = self
  Name_ = Common_::Name
  NEWLINE_ = "\n"
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
  MONADIC_EMPTINESS_ = -> _ {}
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
# #double-tombstone: "wall" (for rbx) (was in "lib-.rb")
# #tombstone - extensive task to build rbx
# :#tombstone: [#005]:#this-node-looks-funny-because-it-is-multi-domain
