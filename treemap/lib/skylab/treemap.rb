require_relative '..'
require 'skylab/callback/core'

module Skylab::Treemap

  Callback_ = ::Skylab::Callback

  class << self

    def describe_into_under y, _
      y << "solid but impcomplete experiment with test coverage visualization"
    end

    define_method :application_kernel_, ( Callback_.memoize do

      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_

      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  module Model_

    define_singleton_method :common_action_class, ( Callback_.memoize do

      class Common_Action_Class___ < Home_.lib_.brazen::Model.common_action_class

        Home_.lib_.brazen::Model.common_entity_module[ self ]

        self
      end
    end )
  end

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  Autoloader_[ Input_Adapters_ = ::Module.new ]
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''
  NIL_ = nil
  Autoloader_[ Output_Adapters_ = ::Module.new, :boxxy ]
  SPACE_ = ' '
  Home_ = self
  UNABLE_ = false

end
