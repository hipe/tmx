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
      @___libs ||= TestSupport_::Library.new Use_, TS_
    end
  end  # >>

#==BEGIN
  module Expect_CLI_or_API

    # experiment: allow CLI and API tests of a common-enough complexity to
    # co-exist side-by-side in the same node.

    def self.[] tcc
      tcc.include self
    end

    # -- modeling the invocation-under-test of your CLI or API

    def invoke * argv
      @API_OR_CLI = :CLI
      @CLI = TS_::Non_Interactive_CLI::Fail_Early::Client_for_Expectations_of_Invocation.new
      @CLI.invoke_via_argv argv
      NIL
    end

    def call * x_a
      _init_for_call_to_API_ZE
      @API.receive_call x_a
      NIL
    end

    def call_by & p
      _init_for_call_to_API_ZE
      @API.call_by( & p )
      NIL
    end

    def _init_for_call_to_API_ZE
      @API_OR_CLI = :API
      @API = Common_.test_support::Expect_Emission_Fail_Early::Spy.new
      NIL
    end

    # -- line-oriented expectations of emission..

    # ~ of CLI

    def expect_on_stderr s
      @CLI.expect_on_stderr s
    end

    def expect_on_stdout s
      @CLI.expect_on_stdout s
    end

    def on_stream sym
      @CLI.on_stream sym
    end

    def expect_styled_line * chunks
      @CLI.expect_styled_line_via chunks
    end

    def expect_each_by & p
      @CLI.expect_each_by( & p )
    end

    # ~ shared syntax

    def expect *a, &p
      send EXPECT___.fetch( @API_OR_CLI ), a, & p
    end

    EXPECT___ = { API: :_expect_for_API_ZE, CLI: :__expect_for_CLI_ZE }

    def __expect_for_CLI_ZE a
      @CLI.expect( * a )
    end

    # ~ of API

    def ignore_emissions_whose_terminal_channel_symbol_is sym
      @API.add_ignore_terminal_channel_symbol sym
      NIL
    end

    def expect_these_lines_on_stderr
      # experiment - not ideal because it confuses who's driving
      on_stream :serr
      _y = ::Enumerator::Yielder.new do |line|
        expect line
      end
      yield _y
      NIL
    end

    def expect_these_lines_via_expect_fail * chan, & p
      _msgs = _messages_via_expect_fail_ZE chan
      expect_these_lines_in_array _msgs, & p
    end

    def messages_via_expect_fail * chan
      _messages_via_expect_fail_ZE chan
    end

    def _messages_via_expect_fail_ZE chan
      msgs = nil
      _expect_for_API_ZE chan do |y|
        msgs = y
      end
      expect_fail
      msgs
    end

    def _expect_for_API_ZE a, & p
      @API.expect_emission p, a
    end

    # -- finishers

    def expect_fail
      send EXPECT_FAIL___.fetch @API_OR_CLI
    end

    EXPECT_FAIL___ = {
      API: :_expect_nil_result_for_API_ZE,
      CLI: :__expect_fail_for_CLI_ZE,
    }

    def __expect_fail_for_CLI_ZE
      @CLI.expect_fail_under self
    end

    def _expect_nil_result_for_API_ZE

      # [#ze-026.1] NIL (not FALSE) happens when failure :#here

      @API.expect_result_under NIL, self
    end

    def expect_succeed
      send EXPECT_SUCCEED___.fetch @API_OR_CLI
    end

    EXPECT_SUCCEED___ = {
      API: :__expect_succeed_for_API_ZE,
      CLI: :__expect_succeed_for_CLI_ZE,
    }

    def __expect_succeed_for_CLI_ZE
      @CLI.expect_succeed_under self
    end

    def __expect_succeed_for_API_ZE

      # [#ze-026.1] NIL (not TRUE) happens when success :#here

      @API.expect_result_under NIL, self
    end

    def expect_result x
      @API.expect_result_under x, self
    end

    def execute
      @API.execute_under self
    end

    def finish_by & p
      @API.receive_finish_by p, self
    end

    # ~

    def DEBUG_ALL_BY_FLUSH_AND_EXIT
      send DEBUG_etc___.fetch @API_OR_CLI
    end

    DEBUG_etc___ = { API: :__DEBUG_for_API_ZE, CLI: :__DEBUG_for_CLI_ZE }

    def __DEBUG_for_CLI_ZE
      @CLI.DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER self
    end

    def __DEBUG_for_API_ZE
      @API.DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER self
    end

    def expression_agent
      send EXPAG___.fetch @API_OR_CLI
    end

    EXPAG___ = { API: :expression_agent_for_API, CLI: :expression_agent_for_CLI }

    def expression_agent_for_CLI
      ::Kernel._K
    end

    def expression_agent_for_API
      ::NoDependenciesZerk::API_InterfaceExpressionAgent.instance  # ..
    end

    # -- practically (if not actually) functions & derivatives

    def expect_these_lines_in_messages & p
      expect_these_lines_in_array messages, & p
    end

    def expect_these_lines_in_array actual_messages, & p

      TestSupport_::Expect_these_lines_in_array[ actual_messages, p, self ]
    end

    # ~ shameless copy-paste from [#co-065] - will go away if it interferes

    def black_and_white ev
      _expag = black_and_white_expression_agent_for_expect_emission
      ev.express_into_under "", _expag
    end

    def black_and_white_lines ev
      _expag = black_and_white_expression_agent_for_expect_emission
      ev.express_into_under [], _expag
    end
  end

#==END

  TestSupport_ = ::Skylab::TestSupport
  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  Home_ = ::Skylab::Zerk
  Common_ = Home_::Common_
  Autoloader__ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  # -
    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end
  # -

  # -

    # --

    def build_root_ACS  # cp from [ac]
      subject_root_ACS_class.new_cold_root_ACS_for_expect_root_ACS
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def event_log_
      Common_.test_support::Expect_Emission::Log
    end

    # --

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
    Common_::KnownKnown[ x ]
  end

  # -- mode-specific

  Hackily_unwrap_wrapped_line_ = -> line do
    # (when you're not sure if you're gonna keep the line-unwrapping behavior)
    md = %r(\A(.+)\. (.+)\z).match line
    md or fail "\". \" -- #{ line.inspect }"
    [ md[1], md[2] ]
  end

  Remote_CLI_lib_ = Lazy_.call do
    # (in the asset tree we keep mention of "CLI" out of the toplevel, but for
    # the 2/3 of tests that need this, it's too annoying not to put it here)
    Home_.lib_.brazen::CLI_Support
  end

  # -- test lib nodes

  module Use_

    CLI_table = -> tcc do
      TS_::CLI_Table[ tcc ]
    end

    module My_API

      def self.[] tcc
        TS_::API[ tcc ]
        tcc.include self
      end

      def zerk_API_call oes_p, x_a
        @root_ACS ||= subject_root_ACS_class.new_cold_root_ACS_for_expect_root_ACS
        Home_::API.call( x_a, @root_ACS ) { |_| oes_p }
      end
    end

    Expect_emission_fail_early = -> tcc do
      Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
    end

    Expect_event = -> tcc do
      Common_.test_support::Expect_Emission[ tcc ]
    end

    Expect_stdout_stderr = -> tcc do
      tcc.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  # --

  Expect_no_emission_ = -> * i_a do
      fail "unexpected: #{ i_a.inspect }"
  end

  # --

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  # --

  # --

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  Basic_ = Home_::Basic_
  DASH_ = '-'
  EMPTY_A_ = []
  EMPTY_P_ = Home_::EMPTY_P_
  EMPTY_S_ = "".freeze
  MONADIC_EMPTINESS_ = Home_::MONADIC_EMPTINESS_
  NEWLINE_ = Home_::NEWLINE_
  No_deps_zerk_ = Home_::No_deps_zerk_
  NIL_ = nil
  NOTHING_ = Home_::NOTHING_
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
