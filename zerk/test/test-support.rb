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

  module Fixture_Top_ACS_Classes
    Autoloader__[ self ]
    Here_ = self
  end

  # -- exp

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

  class Future_Expect_ < ::Proc  # #todo probably away this

    class << self

      def _call * expected_sym_a

        p = nil

        o = new do | * sym_a, & ev_p |
          p[ * sym_a, & ev_p ]
        end

        Callback_.test_support::Future_Expect[ o.singleton_class ]

        o.add_future_expect expected_sym_a

        p = o.fut_p

        o
      end

      alias_method :[], :_call

      alias_method :call, :_call
    end  # >>

    def do_debug
      false
    end

    def done_
      future_is_now
    end
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  EMPTY_A_ = []
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = "".freeze
  MONADIC_EMPTINESS_ = Home_::MONADIC_EMPTINESS_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  NOTHING_ = Home_::NOTHING_
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNABLE_ = false
end
