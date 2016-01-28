require 'skylab/callback'

module Skylab::MyTerm

  def self.describe_into_under y, _expag
    y << "for OS X and iTerm 2: identify terminals thru label as background image"
  end

  module API
    class << self
      def call * x_a, & pp

        # (for now, every API call starts with a new empty root ACS)
        # (but remember there is a kernel that is "long-running")

        _ACS = Home_.__build_root_ACS
        _ze = Home_.lib_.zerk

        _x = _ze::API.call x_a, _ACS, & pp

        _x
      end
    end  # >>
  end

  class << self

    def __build_root_ACS  # (break down as needed)

      _cls = Home_::Models_::Appearance
      _k = ___custom_kernel
      _cls.new _k
    end

    def ___custom_kernel
      @___custom_kernel ||= Custom_Kernel___.new( Home_, :Models_ )
    end

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
  end

  # -- context experiments..

  _LL = nil
  Linked_list_ = -> do
    _LL ||= Home_.lib_.basic::List::Linked
  end

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  # -- Simple functionesques

  _ACS = nil
  ACS_ = -> do
    _ACS ||= Home_.lib_.autonomous_component_system
  end

  # -- Standard support

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]

    Basic = sidesys[ :Basic ]

    Open3 = stdlib[ :Open3 ]

    Shellwords = stdlib[ :Shellwords ]

    system_lib = sidesys[ :System ]

    System = -> do
      system_lib[].services
    end

    Zerk = sidesys[ :Zerk ]
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  Home_ = self
  Autoloader_[ Image_Output_Adapters_ = ::Module.new ]
  Autoloader_[ Models_ = ::Module.new ]
  NIL_ = nil
  UNABLE_ = false
end
