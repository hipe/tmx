require 'skylab/zerk'
require 'skylab/test_support'

module Skylab::Zerk::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include TS_
    end

    def lib sym
      _libs.public_library sym
    end

    def lib_ sym
      _libs.protected_library sym
    end

    def _libs
      @___libs ||= TestSupport_::Library.new TS_
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport
  extend TestSupport_::Quickie

  Home_ = ::Skylab::Zerk
  Callback_ = Home_::Callback_
  Autoloader__ = Callback_::Autoloader
  Lazy_ = Callback_::Lazy

  # -
    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end
  # -

  # -

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  # -

  # -- fixtures & mocks

  My_fixture_top_ACS_class = -> const do
    Fixture_Top_ACS_Classes.const_get const, false
  end

  need_ACS = true

  Remote_fixture_top_ACS_class = -> const do
    need_ACS && Require_ACS_for_testing_[]
    ACS_.test_support::Fixture_top_ACS_class[ const ]
  end

  Require_ACS_for_testing_ = -> do

    # NOTE this *must* be different than the one in the asset tree -
    # a) this sets a different constant and b) don't mess with the
    # constant namespace of the asset tree.

    if need_ACS
      need_ACS = false
      ACS_ = Home_.lib_.ACS
      NIL_
    end
  end

  Field_lib_for_testing_ = -> do
    Home_.lib_.fields
  end

  module Fixture_Top_ACS_Classes
    Autoloader__[ self ]
    Sibling_ = self
  end

  # -- support for fixtures

  Primitivesque_model_for_trueish_value_ = -> arg_st do
    x = arg_st.gets_one
    x or self._SANITY
    Callback_::Known_Known[ x ]
  end

  # -- test lib nodes

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_Event[ tcc ]
  end

  Expect_Stdout_Stderr = -> tcc do
    tcc.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
  end

  Future_expect_nothing_ = Lazy_.call do
    -> * i_a do
      fail "unexpected: #{ i_a.inspect }"
    end
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  EMPTY_A_ = []
  EMPTY_P_ = Home_::EMPTY_P_
  EMPTY_S_ = "".freeze
  MONADIC_EMPTINESS_ = Home_::MONADIC_EMPTINESS_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  NOTHING_ = Home_::NOTHING_
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNABLE_ = false
end
