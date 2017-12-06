require 'skylab/common'

module Skylab::MyTerm

  class << self

    def describe_into_under y, _expag
      y << "for OS X and iTerm 2: identify terminals thru label as background image"
    end
  end  # >>

  module API

    # one of the [#ze-001.2] "generated modality clients" (see)

    class << self

      def call * x_a, & pp

        # to the extent that tests don't test the live system, this method
        # is not covered. so stay close to #spot-2.
        # every API call needs its own empty root ACS.

        _ACS = Home_.build_root_ACS_
        Call_[ x_a, _ACS, & pp ]
      end
    end  # >>
  end

  Call_ = -> x_a, acs, & pp do

    Require_zerk_[]
    _x = Zerk_::API.call x_a, acs, & pp
    _x  # #todo
  end

  class << self

    def build_root_ACS_

      _k = Invocation_Kernel___.new Home_::Models_

      Home_::Models_::Appearance.new _k  # :#spot-3
    end

    def lib_

      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  class Invocation_Kernel___  # #test-point

    # although this exists one-to-one (in terms of lifetime) with an
    # "appearance" component (which is the root ACS), we keep it separate
    # for cognitive clarity and focus of scope.
    # this is a modified version of a relic from the [br] way.
    # ..maybe go away, maybe abstract upwards to [ze] or somewhere..

    def initialize models_mod
      @models_module = models_mod
      cache = {}
      @__silo_p = -> k do
        cache.fetch k do
          x = __start_silo k
          cache[k] = x
          x
        end
      end
    end

    def silo k
      @__silo_p[ k ]
    end

    def __start_silo k

      silo_mod = @models_module.const_get k, false

      silo_mod.const_get( :Silo_Daemon, false ).new self, silo_mod
    end

    eek = {}
    define_method :FOREVER_CACHE do  # using this only after reading [#010]
      eek
    end

    def kernel_  # so we ourselves can get passed as proxy for component
      self
    end
  end

  Common_ = ::Skylab::Common

  Autoloader_ = Common_::Autoloader

  module Models_

    Color = -> arg_st, & p_p do  # stowaway

      _String = Home_.lib_.basic::String

      _ = _String.component_model_for :NONBLANK_TOKEN

      _[ arg_st, & p_p ]
    end

    Autoloader_[ self ]
  end

  # -- context experiments..

  _LL = nil
  Linked_list_ = -> do
    _LL ||= Home_.lib_.basic::List::Linked
  end

  # -- Simple functionesques

  Lazy_ = Common_::Lazy

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk ; nil
  end

  Require_ACS_ = Lazy_.call do
    ACS_ = Home_.lib_.arc
    Arc_ = ACS_  # (the new name)
    NIL_
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  # --

  ArgumentError = ::Class.new ::ArgumentError

  # -- Standard support

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    System = -> do
      System_lib[].services
    end

    Arc = sidesys[ :Arc ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Open3 = stdlib[ :Open3 ]
    Shellwords = stdlib[ :Shellwords ]
    System_lib = sidesys[ :System ]
    Zerk = sidesys[ :Zerk ]
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  module Image_Output_Adapters_
    Autoloader_[ self, :boxxy ]
  end

  ACHIEVED_ = true
  EMPTY_S_ = ''
  Home_ = self
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
end
