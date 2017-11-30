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
  module Want_CLI_or_API

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
      @API = Common_.test_support::Want_Emission_Fail_Early::Spy.new
      NIL
    end

    # -- line-oriented expectations of emission..

    # ~ of CLI

    def want_on_stderr s
      @CLI.want_on_stderr s
    end

    def want_on_stdout s
      @CLI.want_on_stdout s
    end

    def on_stream sym
      @CLI.on_stream sym
    end

    def want_styled_line * chunks
      @CLI.want_styled_line_via chunks
    end

    def want_each_by & p
      @CLI.want_each_by( & p )
    end

    # ~ shared syntax

    def want *a, &p
      send Want___.fetch( @API_OR_CLI ), a, & p
    end

    Want___ = { API: :_want_for_API_ZE, CLI: :__want_for_CLI_ZE }

    def __want_for_CLI_ZE a
      @CLI.want( * a )
    end

    # ~ of API

    def ignore_emissions_whose_terminal_channel_symbol_is sym
      @API.add_ignore_terminal_channel_symbol sym
      NIL
    end

    def want_these_lines_on_stderr
      # experiment - not ideal because it confuses who's driving
      on_stream :serr
      _y = ::Enumerator::Yielder.new do |line|
        want line
      end
      yield _y
      NIL
    end

    def want_these_lines_via_want_fail * chan, & p
      _msgs = _messages_via_want_fail_ZE chan
      want_these_lines_in_array _msgs, & p
    end

    def messages_via_want_fail * chan
      _messages_via_want_fail_ZE chan
    end

    def _messages_via_want_fail_ZE chan
      msgs = nil
      _want_for_API_ZE chan do |y|
        msgs = y
      end
      want_fail
      msgs
    end

    def _want_for_API_ZE a, & p
      @API.want_emission p, a
    end

    # -- finishers

    def want_fail
      send WANT_FAIL___.fetch @API_OR_CLI
    end

    WANT_FAIL___ = {
      API: :_want_nil_result_for_API_ZE,
      CLI: :__want_fail_for_CLI_ZE,
    }

    def __want_fail_for_CLI_ZE
      @CLI.want_fail_under self
    end

    def _want_nil_result_for_API_ZE

      # [#ze-026.1] NIL (not FALSE) happens when failure :#here

      @API.want_result_under NIL, self
    end

    def want_succeed
      send WANT_SUCCEED___.fetch @API_OR_CLI
    end

    WANT_SUCCEED___ = {
      API: :__want_succeed_for_API_ZE,
      CLI: :__want_succeed_for_CLI_ZE,
    }

    def __want_succeed_for_CLI_ZE
      @CLI.want_succeed_under self
    end

    def __want_succeed_for_API_ZE

      # [#ze-026.1] NIL (not TRUE) happens when success :#here

      @API.want_result_under NIL, self
    end

    def want_result x
      @API.want_result_under x, self
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
      Expag_for_API__[]
    end

    # -- practically (if not actually) functions & derivatives

    def want_these_lines_in_messages & p
      want_these_lines_in_array messages, & p
    end

    # :#here3
    def want_these_lines_in_array actual_messages, & p

      TestSupport_::Want_these_lines_in_array[ actual_messages, p, self ]
    end

    # ~ shameless copy-paste from [#co-065] - will go away if it interferes

    def black_and_white ev
      _expag = black_and_white_expression_agent_for_want_emission
      ev.express_into_under "", _expag
    end

    def black_and_white_lines ev
      _expag = black_and_white_expression_agent_for_want_emission
      ev.express_into_under [], _expag
    end
  end

#==END

  # - :#here2

    def want_these_lines_in_array_with_trailing_newlines_ a, & p  # like #here3 but meh
      TestSupport_::Want_Line::
          Want_these_lines_in_array_with_trailing_newlines[ a, p, self ]
    end

    def expression_agent_for_CLI
      Expag_for_CLI___[]
    end

    def expression_agent_for_API
      Expag_for_API__[]
    end
  # -

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
      subject_root_ACS_class.new_cold_root_ACS_for_want_root_ACS
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def event_log_
      Common_.test_support::Want_Emission::Log
    end

    # --

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # (re-opens #here2)
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

  Expag_for_CLI___ = -> do
    No_deps_zerk_[]::CLI_InterfaceExpressionAgent.instance
  end

  Expag_for_API__ = -> do
    No_deps_zerk_[]::API_InterfaceExpressionAgent.instance
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

      def zerk_API_call p, x_a
        @root_ACS ||= subject_root_ACS_class.new_cold_root_ACS_for_want_root_ACS
        Home_::API.call( x_a, @root_ACS ) { |_| p }
      end
    end

    Want_emission_fail_early = -> tcc do
      Common_.test_support::Want_Emission_Fail_Early[ tcc ]
    end

    Want_event = -> tcc do
      Common_.test_support::Want_Emission[ tcc ]
    end

    Want_stdout_stderr = -> tcc do
      tcc.include TestSupport_::Want_Stdout_Stderr::Test_Context_Instance_Methods
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  # --

  Want_no_emission_ = -> * i_a do
      fail "unexpected: #{ i_a.inspect }"
  end

  # --

  Array_via_scanner_ = -> scn do  # scanners are better than arrays - don't promote
    a = []
    until scn.no_unparsed_exists
      a.push scn.gets_one
    end
    a
  end

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
  NIL = nil  # open [#sli-016.C]
    FALSE = false ; TRUE = true
  NOTHING_ = Home_::NOTHING_
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
