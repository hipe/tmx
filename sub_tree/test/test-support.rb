require 'skylab/sub_tree'

module Skylab::SubTree::TestSupport

  class << self

    def [] tcc  # "test context class"
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end

    cache = {}
    define_method :lib_ do | sym |
      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end
  end  # >>

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  TestSupport_ = Autoloader_.require_sidesystem :TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  module Module_Methods___

    def use sym, * x_a
      TS_.lib_( sym )[ self, * x_a ]
    end
  end

  module Instance_Methods___

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def fixture_tree sym
      TestSupport_::Fixtures.tree sym
    end

    def subject_API_value_of_failure
      FALSE
    end

    def subject_API
      Home_::API
    end
  end

  Expect_Event = -> tcc do

    tcc.include Common_.test_support::Expect_Emission::Test_Context_Instance_Methods
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::SubTree

  DASH_ = Home_::DASH_
  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = nil
    FALSE = false ; TRUE = true  # #open [#sli-116.C]
  TS_ = self
  UNDERSCORE_ = Home_::UNDERSCORE_
end
