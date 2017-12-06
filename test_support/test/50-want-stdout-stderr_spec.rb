# frozen_string_literal: true

require_relative 'test-support'

module Skylab::TestSupport::TestSupport

  # three laws for real

  describe "[ts] want stdout stderr" do

    TS_[ self ]
    use :memoizer_methods

    it "the module loads" do
      subject || fail
    end

    it "the module has instance methods as part of its public API" do
      subject::Test_Context_Instance_Methods
    end

    context 'with empty expectation' do  # #coverpoint3.1

      it 'the default expectation is not to expect styled' do
        _want_expectation_not_is_styled
        _want_expectation_YUCK_this_method nil
      end

      it %(no matter what, against a line with no newline you're gonna fail) do
        _against_emission _emission_that_is_not_styled_with_no_newline
        _s = _flush_message
        _s == %<all lines must be newline terminated (had: "hi")> || fail
      end

      it 'against presumably any emission with newline - ok' do
        _against_emission _emission_that_is_not_styled_and_has_newline
        _want_emission_does_match
      end

      shared_subject :_expectation do
        _build_sout_serr_expectation
      end
    end

    context 'with expectation of styled' do

      it 'the expectation reflects that it is styled' do
        _want_expectation_is_styled
      end

      it 'aganst emisssion that is not styled but yes newline - whine' do
        _against_emission _emission_that_is_not_styled_and_has_newline
        _s = _flush_message
        _s ==  %(expected styled, was not: "hi") || fail
      end

      it 'is styled and has newline - ok' do
        _against_emission _emission_that_is_styled_and_has_newline
        _want_emission_does_match
      end

      shared_subject :_expectation do
        _build_sout_serr_expectation :styled
      end
    end

    context 'with expectation that is just REGEXP (NOTE - no newline in expectation regexp)' do

      it 'it reflects the channel and etc' do
        _want_expectation_YUCK_this_method :_curate_content_when_regexp_
      end

      it 'does not match regexp - whine' do
        _against_emission _emission_that_is_not_styled_and_has_newline_and_says_hello
        _s = _flush_message
        expect( _s ).to _be_message_for_regexp 'hello', _this_rx
      end

      it 'matches regexp - ok' do
        _against_emission _emission_that_is_not_styled_and_has_newline_and_says_hi
        _want_emission_does_match[ :yerp ] == 'hi' || fail  # yikes
      end

      shared_subject :_expectation do
        _build_sout_serr_expectation _this_rx
      end

      def _this_rx
        %r(\A(?<yerp>hi)\z)
      end
    end

    context 'with expectation that is just STRING (NOTE - no newline in expectation string)' do

      it 'it reflects the channel and etc' do
        _want_expectation_YUCK_this_method :_curate_content_when_string_
      end

      it 'is not same string - whine' do
        _against_emission _emission_that_is_not_styled_and_has_newline_and_says_hello
        _s = _flush_message
        expect( _s ).to _be_message_for_string 'hello', 'hi'
      end

      it 'is same string - ok' do
        _against_emission _emission_that_is_not_styled_and_has_newline_and_says_hi
        _want_emission_does_match
      end

      shared_subject :_expectation do
        _build_sout_serr_expectation 'hi'
      end
    end

    context 'integration - expect styled on channel with regexp' do

      it 'much reflection wow' do
        _expectation.want_is_styled || fail
        _want_expectation_stream_symbol :chan_meh
        _want_expectation_YUCK_this_method :_curate_content_when_regexp_
      end

      it 'aggregate failure has failure for channel' do
        _contains 'expected stream symbol :chan_meh, had :chan_zerro'
      end

      it 'aggregate failure has failurr for styled' do
        _contains 'expected styled, was not: "hello"'
      end

      it 'aggregate failure has failure for failure to match regexp' do
        _contains 'string did not match (?-mix:fa fa) - "hello"'
      end

      def _contains s
        __simple_custom_index[ s ] || fail
      end

      shared_subject :__simple_custom_index do

        h = {}
        _against_emission _emission_that_is_not_styled_and_has_newline_and_says_hello
        _big_s = _flush_message
        _s_a = _common_split _big_s  # see
        _s_a.each do |s|
          h[ s ] = true
        end
        h
      end

      it 'succeeds' do
        _em = _build_mock_emission :chan_meh, "ohai fa fa\e[32m!\e[0m\n"
        _against_emission _em
        _want_emission_does_match
      end

      shared_subject :_expectation do
        _build_sout_serr_expectation :styled, :chan_meh, %r(fa fa)
      end
    end

    shared_subject :_emission_that_is_styled_and_has_newline do
      _build_mock_emission :chan_uno, "\e[33mhi\e[0m\n"
    end

    shared_subject :_emission_that_is_not_styled_and_has_newline_and_says_hello do
      _build_mock_emission :chan_zerro, "hello\n"
    end

    shared_subject :_emission_that_is_not_styled_and_has_newline_and_says_hi do
      _build_mock_emission :chan_zerro, "hi\n"
    end
    alias_method :_emission_that_is_not_styled_and_has_newline,
      :_emission_that_is_not_styled_and_has_newline_and_says_hi

    shared_subject :_emission_that_is_not_styled_with_no_newline do
      _build_mock_emission :chan_zerro, 'hi'
    end

    def _build_mock_emission chan, line_s
      X_wss_Mock_Emission.new chan, line_s
    end

    def _flush_message
      yn, matcher = _flush_comparison
      false == yn || fail
      matcher.failure_message
    end

    def _want_emission_does_match
      yn_x, _matcher = _flush_comparison
      yn_x || fail
    end

    def _flush_comparison
      _line_o = remove_instance_variable :@EMISSION
      _exp = _expectation
      matcher = _exp.to_matcher_bound_to :no_TCC_TS
      _yn = matcher.matches? _line_o
      [ _yn, matcher ]
    end

    def _against_emission em
      @EMISSION = em ; nil
    end

    def _want_expectation_YUCK_this_method m
      _expectation.method_name_for_curate_content == m || fail
    end

    def _want_expectation_stream_symbol sym
      _expectation.stream_symbol == sym || fail
    end

    def _want_expectation_not_is_styled
      _expectation.want_is_styled == false || fail
    end

    def _want_expectation_is_styled
      _expectation.want_is_styled == true || fail
    end

    def _build_sout_serr_expectation * a, & p
      subject::Expectation.via_args a, & p
    end

    context "with spy" do

      it "CHANNEL - does match does match" do
        add_mock_emission :err, Home_::NEWLINE_
        want :err
        _expect_no_messages
      end

      it "CHANNEL - does not match does not match" do
        add_mock_emission :out, Home_::NEWLINE_
        want :err
        expect( _only_message ).to _be_message_for_stream :out, :err
      end

      it "CHANNEL - X (no emission)" do
        want :err
        expect( _only_message ).to _be_message_for_had_no_emissions
      end

      it "CHANNEL STRING - both matches both matches" do
        add_mock_emission :err, "hi\n"
        want :err, 'hi'
        _expect_no_messages
      end

      it "CHANNEL REGEX - both matches both matches" do
        add_mock_emission :out, "hxxxi\n"
        want :out, /xxx/
        _expect_no_messages
      end

      it "STRING - does match does match" do
        add_mock_emission nil, "fizzle\n"
        want 'fizzle'
        _expect_no_messages
      end

      it "STRING - does not match does not match" do
        add_mock_emission nil, "torah\n"
          want 'bright'
        expect( _only_message ).to _be_message_for_string 'torah', 'bright'
      end

      it "REGEX - does match does match" do
        add_mock_emission nil, "Kelly Clark\n"
        want %r(\bkelly\b)i
        _expect_no_messages
      end

      it "REGEX - does not match does not match" do
        rx = %r(hannah teeter)
        add_mock_emission nil, "Kaitlyn Farrington\n"
        want rx
        expect( _only_message ).to _be_message_for_regexp 'Kaitlyn Farrington', rx
      end

      it 'overrun' do
        add_mock_emission :out, "hey\e[32mhi\e[0mhey"
        _touch_mock_test_context.want_no_more_lines  # #here2
        _s = _only_message
        _rx = %r(\Aexpected no more lines, had \[:out, "he)
        _rx =~ _s || fail
      end

      def add_mock_emission i, x
        _em = X_wss_Mock_Emission.new i, x
        __init_mock_test_context.__add_emission_ _em
        nil
      end

      def want * a, & p
        _touch_mock_test_context.want( * a, & p )
      end

      def __init_mock_test_context
        did = nil
        @MOCK_TEST_CONTEXT ||= begin
          did = true
          X_wss_Spy_One.new
        end
        did || TS_._REFACTOR_ME__to_make_this_work__easy__
        @MOCK_TEST_CONTEXT
      end

      def _touch_mock_test_context
        @MOCK_TEST_CONTEXT ||= X_wss_Spy_One.new
      end

      def _expect_no_messages
        # we want that the matcher that just matched against actual stuff
        # emitted no message.
        _s_a = _flush_big_strings
        _s_a.length.zero? || fail
      end

      def _flush_big_strings
        _mtc = remove_instance_variable :@MOCK_TEST_CONTEXT
        _mtc.__donezo_
      end
    end

    def _be_message_for_regexp s, rx
      eql %(string did not match #{ rx } - #{ s.inspect })
    end

    def _be_message_for_string act_s, exp_s
      eql %(expected string #{ exp_s.inspect }, had #{ act_s.inspect })
    end

    def _be_message_for_stream act_sym, exp_sym
      eql "expected stream symbol :#{ exp_sym }, had :#{ act_sym }"
    end

    def _be_message_for_had_no_emissions
      eql 'expected an emission, had none'
    end

    def _only_message
      _big_s_a = _flush_big_strings
      a = []
      _big_s_a.each do |big_s|
        _s_a = _common_split big_s
        a.concat _s_a
      end
      1 == a.length || fail
      a.fetch 0
    end

    def _common_split big_s

      # expect that the message was "one big string" with many lines. for
      # better or worse, the last 'line' of this big string is not newline
      # terminated, meaning we use [#sar-011] separator semantics and not
      # terminator (LTS) semantics. ensure this below.

      s_a = big_s.split Home_::NEWLINE_, -1
      s_a.last == EMPTY_S_ && fail  # ensure separator not terminator semantics
      s_a
    end

    def subject
      Home_::Want_Stdout_Stderr
    end

    class X_wss_Spy_One

      # get ready to get confused

          def initialize
            @_big_string_array = []
            @_baked_em_a = []
          end

          include Home_::Want_Stdout_Stderr::Test_Context_Instance_Methods

          public(
            :want,
            :want_no_more_lines,  # #here2
          )

          def __add_emission_ _em
            @_baked_em_a.push _em ; nil
          end

          # --

          def flush_baked_emission_array
            remove_instance_variable( :@_baked_em_a ).freeze
          end

          # --

          def quickie_fail_with_message_by
            _big_s = yield
            @_big_string_array.push _big_s
            UNABLE_
          end

          def __donezo_
            remove_instance_variable( :@_big_string_array ).freeze
          end
    end

    X_wss_Mock_Emission = ::Struct.new :stream_symbol, :string

    # ==
    # ==
  end
end
# #tombstone-A.2: instance methods monolith now depends on matcher, tombstone lots of text context mock
# #history-A.1: cleaned thing up just for eradication of should but spying is legacy
