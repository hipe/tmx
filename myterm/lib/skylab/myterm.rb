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

      bx = ACS_[]::Modalities::Reactive_Tree::Dynamic_Source_for_Unbounds.new
      bx.fallback_module = Models_

      Brazen_::Kernel.new Home_ do | kr |

        bx.add :Appearance, Models_::Appearance::Silo_Daemon.new( kr )
        kr.reactive_tree_seed = bx
        NIL_
      end
    end )

    def lib_

      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  # ~ simple stowaways, functions

  ACS_ = -> do
    Brazen_::Autonomous_Component_System
  end

  Autoloader_[ Image_Output_Adapters_ = ::Module.new ]

  # ~ standard support

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    System = sidesys[ :System ]
  end

  ACHIEVED_ = true
  Home_ = self
  Autoloader_[ Models_ = ::Module.new ]
  NIL_ = nil
  UNABLE_ = false
end
