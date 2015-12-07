require 'skylab/brazen'

module Skylab::MyTerm

  def self.describe_into_under y, _expag
    y << "for OS X and iTerm 2: identify terminals thru label as background image"
  end

  Brazen_ = ::Skylab::Brazen
  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  stowaway :CLI do

    class CLI < Brazen_::CLI

      def back_kernel
        Home_.application_kernel_
      end

      self
    end
  end

  class << self

    define_method :application_kernel_, ( Callback_.memoize do

      Build_default_application_kernel___[]
    end )

    def lib_

      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Build_default_application_kernel___ = -> do

    bx = ACS_[]::Modalities::Reactive_Tree::Dynamic_Source_for_Unbounds.new
    bx.fallback_module = Models_

    Brazen_::Kernel.new Home_ do | kr |

      _sd = Models_::Appearance::Silo_Daemon.new kr

      bx.add :Appearance, _sd

      kr.reactive_tree_seed = bx

      NIL_
    end
  end

  # -- context experiments..

  _LL = nil
  Linked_list_ = -> do
    _LL ||= Home_.lib_.basic::List::Linked
  end

  # -- Simple stowaways, functions

  _ACS = nil
  ACS_ = -> do
    _ACS ||= Home_.lib_.autonomous_component_system
  end

  Autoloader_[ Image_Output_Adapters_ = ::Module.new ]

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
  end

  ACHIEVED_ = true
  Home_ = self
  Autoloader_[ Models_ = ::Module.new ]
  NIL_ = nil
  UNABLE_ = false
end
