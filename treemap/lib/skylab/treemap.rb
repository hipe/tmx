require 'skylab/common'

module Skylab::Treemap

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  class << self

    def describe_into_under y, _
      y << "solid but impcomplete experiment with test coverage visualization"
    end

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end

    define_method :application_kernel_, ( Lazy_.call do

      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_

      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  # == these

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x ; instance_variable_set ivar, x ; ACHIEVED_ ; else x end
  end

  # == model support

  module Model_

    define_singleton_method :common_action_class, ( Lazy_.call do

      class Common_Action_Class___ < Home_.lib_.brazen::Action

        Home_.lib_.brazen::Modelesque.entity self

        self
      end
    end )
  end

  # ==

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  # == functions

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  # ==

  Require_basic_ = Lazy_.call do
    Basic_ = Home_.lib_.basic
    NIL
  end

  # ==

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]
  end

  ACHIEVED_ = true
  Autoloader_[ Input_Adapters_ = ::Module.new ]
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
  Autoloader_[ Output_Adapters_ = ::Module.new, :boxxy ]
  SPACE_ = ' '
  Home_ = self
  UNABLE_ = false
end
