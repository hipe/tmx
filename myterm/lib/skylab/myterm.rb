require 'skylab/callback'

module Skylab::MyTerm

  class << self

    def describe_into_under y, _expag
      y << "for OS X and iTerm 2: identify terminals thru label as background image"
    end
  end  # >>

  module API
    # one of the [#015] "generated modality clients" (see)
    class << self
      def call * x_a, & pp

        # (for now, every API call starts with a new empty root ACS)
        # (but remember there is a kernel that is "long-running")

        _ACS = Home_.build_root_ACS_
        Call_[ x_a, _ACS, & pp ]
      end  # :cp1
    end  # >>
  end

  Call_ = -> x_a, acs, & pp do

    Require_zerk_[]
    _x = Zerk_::API.call x_a, acs, & pp
    _x  # #todo
  end

  class << self

    def build_root_ACS_  # (break down as needed)

      Home_::Models_::Appearance.new ___custom_kernel
    end  # :cp3

    def ___custom_kernel

      @___custom_kernel ||= Custom_Kernel___.new Home_, :Models_
    end  # :cp2

    def lib_

      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  class Custom_Kernel___

    # this is a modified version of a relic from the [br] way.
    # ..maybe go away, maybe abstract upwards to [ze] or somewhere..

    def initialize home_mod, models_const

      cache = {}

      @_p = -> k do

        cache.fetch k do

          _Models = home_mod.const_get models_const, false

          silo_mod = _Models.const_get k, false

          _silo_daemon_class = silo_mod.const_get :Silo_Daemon, false

          silo_daemon = _silo_daemon_class.new self, silo_mod

          cache[ k ] = silo_daemon

          silo_daemon
        end
      end
    end

    def silo k
      @_p[ k ]
    end

    def kernel_  # so we ourselves can get passed as proxy for component
      self
    end
  end

  # -- context experiments..

  _LL = nil
  Linked_list_ = -> do
    _LL ||= Home_.lib_.basic::List::Linked
  end

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  # -- Simple functionesques

  Lazy_ = Callback_::Lazy

  Common_fuzzy_retrieve_ = -> do
    Home_.lib_.brazen::Collection::Common_fuzzy_retrieve
  end

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk ; nil
  end

  Require_ACS_ = Lazy_.call do
    ACS_ = Home_.lib_.autonomous_component_system
    NIL_
  end

  # -- Standard support

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]

    Open3 = stdlib[ :Open3 ]

    Shellwords = stdlib[ :Shellwords ]

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    Zerk = sidesys[ :Zerk ]
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  EMPTY_S_ = ''
  Home_ = self
  Autoloader_[ Image_Output_Adapters_ = ::Module.new ]
  Autoloader_[ Models_ = ::Module.new ]
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
end
