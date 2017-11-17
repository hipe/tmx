module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI::Fail_Early  # (incidental code notes in [#064])

    def self.[] tcc
      tcc.include self
    end

    # -

      def prepare_CLI_by & p
        _ze_niCLI_client.prepare_CLI_by = p
      end

      def invoke * argv
        _ze_niCLI_client.invoke_via_argv argv
      end

      def invoke_via_argv argv
        _ze_niCLI_client.invoke_via_argv argv
      end

      def want_empty_puts
        @ze_niCLI_client.want nil
      end

      def want_line_by m=nil, & p
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_line_by( & p )
      end

      def want_each_on_stdout_by m=nil, & p
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_each_on_stdout_by( & p )
      end

      def want_each_on_stderr_by m=nil, & p
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_each_on_stderr_by( & p )
      end

      def want_each_by m=nil, & p
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_each_by( & p )
      end

      def want_on_stderr_lines_in_big_string m=nil, big_s
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_on_stderr_lines_in_big_string big_s
      end

      def want_on_stdout_lines_in_big_string m=nil, big_s
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_on_stdout_lines_in_big_string big_s
      end

      def want_lines_in_big_string m=nil, big_s
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_lines_in_big_string big_s
      end

      def want_on_stderr m=nil, exp_x
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_on_stderr exp_x
      end

      def want_on_stdout m=nil, exp_x
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want_on_stdout exp_x
      end

      def want m=nil, exp_x
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.want exp_x
      end

      def on_stream sym
        @ze_niCLI_client.on_stream sym
      end

      def DEBUG_ALL_BY_FLUSH_AND_EXIT
        @ze_niCLI_client.DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER self
      end

      def want_fail
        _ze_niCLI_release_client.want_fail_under self
      end

      def want_succeed
        _ze_niCLI_release_client.want_succeed_under self
      end

      def _ze_niCLI_client
        @ze_niCLI_client ||= Client_for_Expectations_of_Invocation.new
      end

      def _ze_niCLI_release_client

        # (for those places where this method is called, the only reason
        #  we release the client is for one test that multiple invocations
        #  (to compare them) from the same test context (test case)), so
        #  that for the subsequent logical case it starts anew..)

        remove_instance_variable :@ze_niCLI_client
      end
    # -
    # ==

    class Client_for_Expectations_of_Invocation

      def initialize
        @_method = :puts
        @_setup = Setup___.new
      end

      def program_name_string_array= x
        @_setup.program_name_string_array= x
      end

      def subject_CLI_by & p
        @_setup.subject_CLI_by = p ; nil
      end

      def prepare_CLI_by= p
        @_setup.prepare_CLI_by = p ; nil
      end

      def using_method m
        @_method = m ; nil
      end

      def invoke * argv
        invoke_via_argv argv
      end

      def invoke_via_argv argv
        @_setup.ARGV = argv ; nil
      end

      def want_styled_line_via chunks
        _ = StyledLineExpectation___.new chunks, @_method, @_stream
        @_setup._add _, @_stream
      end

      def want_line_by & p
        __add_proc_for_line_based_expectation p
      end

      def want_each_on_stdout_by & p
        @_stream = :sout
        _add_proc_based_expectation p
      end

      def want_each_on_stderr_by & p
        @_stream = :serr
        _add_proc_based_expectation p
      end

      def want_each_by & p
        _add_proc_based_expectation p
      end

      def want_on_stderr_lines_in_big_string big_s
        @_stream = :serr
        _add_big_string_based_expectation big_s
      end

      def want_on_stdout_lines_in_big_string big_s
        @_stream = :sout
        _add_big_string_based_expectation big_s
      end

      def want_lines_in_big_string big_s
        _add_big_string_based_expectation big_s
        NIL
      end

      def __add_proc_for_line_based_expectation p

        @_setup.add_proc_for_line_based_expectation p, @_method, @_stream
        NIL
      end

      def _add_proc_based_expectation p

        @_setup.add_proc_based_expectation p, @_method, @_stream
        NIL
      end

      def _add_big_string_based_expectation big_s

        @_setup.add_big_string_based_expectation big_s, @_method, @_stream
        NIL
      end

      def want_on_stderr exp_x
        @_stream = :serr
        _add_line_based_expectation exp_x
      end

      def want_on_stdout exp_x
        @_stream = :sout
        _add_line_based_expectation exp_x
      end

      def want m=nil, exp_x
        @_method = m if m
        _add_line_based_expectation exp_x
      end

      def _add_line_based_expectation exp_x

        @_setup.add_line_based_expectation exp_x, @_method, @_stream
        NIL
      end

      def on_stream serr_or_sout
        @_stream = serr_or_sout ; nil
      end

      def DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER tc

        @_stream ||= :serr
        io = tc.debug_IO
        if tc.do_debug
          io.puts "(because debugging is on we're not to echo line output)"
          p = MONADIC_EMPTINESS_
        else
          io.puts "(going to flush and exit the lines from #{ @_stream })"
          p = io.method :puts
        end
        want_each_by( & p )
        invo = _invocation_under( tc ).execute
        d = invo.exitstatus
        io.puts "(exitstatus: #{ d } from invocation under test -- GOODBYE FROM [ze])"
        ::Kernel.exit 0
      end

      def want_fail_under tc
        _invocation_under( tc ).execute.__want_failed
      end

      def want_succeed_under tc
        _invocation_under( tc ).execute.__want_succeeded
      end

      def _invocation_under tc
        InvocationUnderExpectations__.new @_setup, tc
      end

      # -- convenience functions

      def unstyle_styled line
        # (this could be better integrated but for now meh KISS)
        Home_::CLI::Styling::Unstyle_styled[ line ]
      end
    end

    # ==

    DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__ = -> msg do
      ::Kernel.fail ExpectationFailure__, msg
    end

    # ==

    class InvocationUnderExpectations__

      def initialize setup, tc
        @setup = setup
        @test_context = tc
      end

      def execute
        __init_CLI_and_spies @setup.ARGV
        @exitstatus = @_CLI.execute
        remove_instance_variable( :@_spy ).finished_invoking_notify
        self
      end

      # ~

      def __want_failed
        if @exitstatus.zero?
          __when_exitstatus_zero
        end
      end

      def __when_exitstatus_zero
        fail_say "expected nonzero exitstatus, had zero"
      end

      # ~

      def __want_succeeded
        if @exitstatus.nonzero?
          __when_exitstatus_nonzero
        end
      end

      def __when_exitstatus_nonzero
        fail_say "expected zero exitstatus, had #{ @exitstatus }"
      end

      # ~

      def __init_CLI_and_spies argv

        setup = @setup ; tc = @test_context

        p = setup.subject_CLI_by
        if p
          classish = p.call
        else
          classish_came_from_test_context = true
          classish = tc.subject_CLI
        end

        kn = setup.program_name_string_array_knownness
        _pn_s_a = if kn
          kn.value
        else
          __program_name_string_array
        end

        spy = Spy___.new setup, tc

        _stdin = if tc.respond_to? :zerk_niCLI_fail_early_stdin

          # mocking stdin is something that is done so rarely in practice
          # that we make this a #hook-in not #hook-out so that test contexts
          # can test under themselves without needing to define this method.
          tc.zerk_niCLI_fail_early_stdin
        else
          :_ze_stdin_is_NOT_mocked_but_could_be_
        end

        cli = classish.new(
          argv,
          _stdin,
          spy.sout_stream_proxy,
          spy.serr_stream_proxy,
          _pn_s_a,
        )

        p = setup.prepare_CLI_by

        if p
          p[ cli ]
        elsif classish_came_from_test_context
          tc.prepare_subject_CLI_invocation cli
        end

        @_CLI = cli ; @_spy = spy
        NIL
      end

      def __program_name_string_array
        if @test_context.respond_to? :program_name_string_array
          @test_context.program_name_string_array
        else
          %w( ze-pnsa )
        end
      end

      attr_reader(
        :exitstatus,
      )

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__
    end

    # ==

    class Spy___

      def initialize setup, tc

        a = setup.expectations
        if ! a
          self._NO_PROBLEM_just_use_empty_a
        end

        @_emission_receiver = EmissionReceiver__.new a, tc

        has = setup.has

        _sout_spy = if has[ :sout ]
          SoutSpy__[].dup_by do |o|
            o.receive_by = method :_receive
          end
        else
          Want_nothing_on__[ :sout ]
        end

        _serr_spy = if has[ :serr ]
          SerrSpy__[].dup_by do |o|
            o.receive_by = method :_receive
          end
        else
          Want_nothing_on__[ :serr ]
        end

        @_sout_spy = _sout_spy
        @_serr_spy = _serr_spy
      end

      def _receive s, method_name, stream_sym

        _act = ActualEmission___.new s, method_name, stream_sym
        @_emission_receiver.receive_emission _act
        NIL
      end

      def finished_invoking_notify
        _er = remove_instance_variable :@_emission_receiver
        _er.finish
        NIL
      end

      # -- simple readers

      def serr_stream_proxy
        @_serr_spy.stream_proxy
      end

      def sout_stream_proxy
        @_sout_spy.stream_proxy
      end
    end

    class SingleStreamAssertionSession___

      # simplified, single-stream counterpart to "spy" above

      def initialize exp_a, ctx

        @_emission_receiver = EmissionReceiver__.new exp_a, ctx

        @downstream_IO_proxy = SingleStreamProxy___.new do |x, m|
          __receive x, m  # hi.
        end
      end

      def __receive x, m

        _act = SingleStreamActualEmission___.new x, m
        @_emission_receiver.receive_emission _act
        NIL
      end

      def finish
        _er = remove_instance_variable :@_emission_receiver
        _er.finish
        NIL
      end

      attr_reader(
        :downstream_IO_proxy,
      )
    end

    # ==

    class ActualEmission___

      def initialize s, m, sym
        @method_name = m
        @serr_or_sout = sym
        @string = s
      end

      def stream_is_OK x
        @serr_or_sout == x
      end

      def express_debugging_into io
        io.puts inspect_actual
      end

      def inspect_actual
        [ @string, @method_name, @serr_or_sout ].inspect
      end

      attr_reader(
        :method_name,
        :serr_or_sout,
        :string,
      )
    end

    class SingleStreamActualEmission___

      # simplified, single-stream counterpart to "actual emission" above

      def initialize s, m
        @method_name = m
        @string = s
      end

      def stream_is_OK _
        :_not_applicable_for_single_stream_ZE_ == _ || self._SANITY
      end

      def express_debugging_into io
        io.puts inspect_actual
      end

      def inspect_actual
        [ @method_name, @string ].inspect
      end

      attr_reader(
        :method_name,
        :string,
      )
    end

    # ==

    class EmissionReceiver__

      def initialize a, tc

        @_is_using_multi_emission_assertion = false
        @_receive = :_receive_emission_normally

        @_expectations_queue = Common_::Scanner.via_array a

        @test_context = tc
      end

      def receive_emission em

        if @test_context.do_debug
          em.express_debugging_into @test_context.debug_IO
        end

        send @_receive, em
      end

      def __receive_emission_when_under_multi_emission_assertion act

        _no_unparsed_exists = @_multi_emission_assertion.receive_emission act
        if _no_unparsed_exists
          remove_instance_variable :@_multi_emission_assertion
          @_is_using_multi_emission_assertion = false
          @_receive = :_receive_emission_normally
        end
        NIL
      end

      def _receive_emission_normally act

        if @_expectations_queue.no_unparsed_exists
          NoMoreEmissionAssertion___.new( act, @test_context ).execute
        else
          exp = @_expectations_queue.gets_one
          if exp.is_multi_emission_expectation

            @_is_using_multi_emission_assertion = true
            @_multi_emission_assertion = exp.to_multi_emission_assertion @test_context
            @_receive = :__receive_emission_when_under_multi_emission_assertion

            send @_receive, act
          else
            exp.assert_against_under act, @test_context
          end
          NIL
        end
      end

      def finish

        if @_is_using_multi_emission_assertion

          @_multi_emission_assertion.finished_invoking_notify
          remove_instance_variable :@_multi_emission_assertion
        end

        remove_instance_variable :@_is_using_multi_emission_assertion
        remove_instance_variable :@_receive

        if ! @_expectations_queue.no_unparsed_exists
          __when_missing_emission
        end
        NIL
      end

      def __when_missing_emission
        _exp = @_expectations_queue.head_as_is
        fail_say "actual output ended when expecting: #{ _exp.inspect_expectation }"
      end

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__
    end

    # ==

    class Setup___

      def initialize
        @expectations = []
        @has = {}
      end

      def program_name_string_array= x
        @program_name_string_array_knownness = Common_::KnownKnown[ x ]
        x
      end

      def add_proc_based_expectation p, m, serr_or_sout
        _add ProcBasedExpectation__.new( p, m, serr_or_sout ), serr_or_sout
      end

      def add_big_string_based_expectation big_s, m, serr_or_sout
        _add BigStringBasedExpectation__.new( big_s, m, serr_or_sout ), serr_or_sout
      end

      def add_line_based_expectation exp_x, method_name, serr_or_sout
        _add Line_based_expectation__[ exp_x, method_name, serr_or_sout ], serr_or_sout
      end

      def add_proc_for_line_based_expectation p, m, serr_or_sout
        _add ProcForLineBasedExpectation___.new( p, m, serr_or_sout ), serr_or_sout
      end

      def _add exp, serr_or_sout
        @has[ serr_or_sout ] = true
        @expectations.push exp
        NIL
      end

      attr_writer(
        :ARGV,
        :prepare_CLI_by,
        :subject_CLI_by,
      )

      attr_reader(
        :ARGV,
        :has,
        :expectations,
        :prepare_CLI_by,
        :program_name_string_array_knownness,
        :subject_CLI_by,
      )
    end

    class SingleStreamExpectations < Common_::SimpleModel

      # simplified, single-stream counterpart to "setup" above

      def initialize
        @expectations = []
        @method_name = :puts
        @serr_or_sout = :_not_applicable_for_single_stream_ZE_
        yield self
        @expectations.freeze
      end

      # -- write

      def want_big_string s
        _add BigStringBasedExpectation__.new( s, @method_name, @serr_or_sout )
      end

      def want_styled_content str, * sym_a

        # (full justification at [#here.A])

        md = THIS_RX___.match str
        # ..
        _styled = Home_::CLI::Styling::Stylify[ sym_a, md[ :content ] ]
        _final = "#{ md[ :margin ] }#{ _styled }"
        want _final
      end

      THIS_RX___ = /\A
        (?<margin>[ \t]*)
        (?<content>.+)
      \z/x  # note that as an implicit assertion and for now, assert no "\n"

      def want exp_x=nil
        _add Line_based_expectation__[ exp_x, @method_name, @serr_or_sout ]
      end

      def _add exp
        @expectations.push exp
        NIL
      end

      # -- read

      def to_assertion_session_under ctx
        SingleStreamAssertionSession___.new @expectations, ctx
      end
    end

    # ==

    # == (forward declarations)

    MethodAndStreamAssertion__ = ::Class.new

    StringBasedAssertion__ = ::Class.new MethodAndStreamAssertion__

    StringBasedExpectation__ = StringBasedAssertion__  # #this-dichotomy

    ExactStringBasedExpectation__ = ::Class.new StringBasedExpectation__

    ExactStringBasedAssertion__ = ExactStringBasedExpectation__  # #this-dichotomy

    # == (end forward declaration)

    class ProcBasedExpectation__

      def initialize p, m, sym
        @method_name = m
        @proc = p
        @serr_or_sout = sym
      end

      def to_multi_emission_assertion tc
        ProcBasedAssertion___.new @proc, @method_name, @serr_or_sout, tc
      end

      def is_multi_emission_expectation
        true
      end
    end

    class ProcBasedAssertion___

      def initialize p, m, sym, tc

        @_reusable_method_and_stream_assertion =
          ResuableMethodAndStreamAssertion___.new m, sym

        @proc = p
        @_recieve_emission = :__receive_first_emission
        @_received_at_least_one_emission = false
        @test_context = tc
      end

      def receive_emission em
        send @_recieve_emission, em
      end

      def __receive_first_emission em
        @_received_at_least_one_emission = true
        @_receive_emission = :__receive_emission_normally
        send @_receive_emission, em
      end

      def __receive_emission_normally em

        @_reusable_method_and_stream_assertion.actual_emission = em
        @_reusable_method_and_stream_assertion.execute

        t_or_f = @proc[ em.string ]
        if true == t_or_f
          ACHIEVED_
        elsif t_or_f.nil?
          NOTHING_
        else
          self._RESULT_IN_TRUE_WHEN_FINISHED_AND_NIL_WHEN_STILL_GOING
        end
      end

      def finished_invoking_notify
        if ! @_received_at_least_one_emission
          fail_say "the proc was never called: #{ @proc.inspect }"
        end
      end

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__
    end

    # ==

    class BigStringBasedExpectation__

      def initialize s, m, sym
        @big_string = s
        @method_name = m
        @serr_or_sout = sym
      end

      def to_multi_emission_assertion tc
        BigStringBasedAssertion___.new @big_string, @method_name, @serr_or_sout, tc
      end

      def inspect_expectation
        [ "«big string»", @serr_or_sout, @method_name ].inspect
      end

      def is_multi_emission_expectation
        true
      end
    end

    class BigStringBasedAssertion___

      def initialize s, m, sym, tc

        @big_string = s
        @method_name = m
        @serr_or_sout = sym
        @test_context = tc

        @_receive = :__receive_first_emission
      end

      def receive_emission em
        send @_receive, em
      end

      def __receive_first_emission em

        _s = remove_instance_variable :@big_string
        @_stream = Basic_[]::String::LineStream_via_String[ _s ]

        @_reusable_assertion = ReusableExactStringBasedAssertion__.new :puts, @serr_or_sout, @test_context

        line = @_stream.gets
        line || self._NO
        line.chop!  # live dangerously
        @_reusable_assertion.string = line

        @_receive = :__receive
        send @_receive, em
      end

      def __receive em

        s = em.string
        if ! s.frozen?
          s.chomp!  # we become indifferent!! EEK for [cm] #todo
        end

        @_reusable_assertion.actual_emission = em
        @_reusable_assertion.execute

        line = @_stream.gets
        if line
          line.chop!  # live dangerously
          @_reusable_assertion.string = line
          NOTHING_
        else
          remove_instance_variable :@_receive
          remove_instance_variable :@_reusable_assertion
          ACHIEVED_
        end
      end

      def finished_invoking_notify

        # any time we're receiving this it means we were not removed from
        # the parent which means we never reached our end

        _ = @_reusable_assertion.inspect_expectation
        fail_say "actual output ended when expecting (in stream): #{ _ }"
      end

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__
    end

    # ==

    class ReusableExactStringBasedAssertion__ < ExactStringBasedAssertion__

      def initialize method_name, serr_or_sout, tc
        __init_string_based_expectation method_name, serr_or_sout
        @test_context = tc
      end

      attr_writer(
        :actual_emission,
        :string,
      )

      def execute
        # hi.
        super
      end
    end

    # ==

    class NoMoreEmissionAssertion___  # (exists only to explain failure)

      def initialize act, tc
        @actual_emission = act
        @test_context = tc
      end

      def execute
        fail_say "when no more emissions were expected, had #{ @actual_emission.inspect_actual }"
      end

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__

      def is_multi_emission_expectation
        false
      end
    end

    Line_based_expectation__ = -> x, m, sym do
      if x
        if x.respond_to? :ascii_only?
          ExactStringBasedExpectation__.new x, m, sym
        elsif x.respond_to? :named_captures
          RegexpBasedStringExpectation__.new x, m, sym
        else
          TS_._NO
        end
      else
        BlankLineExpectation___.new m, sym
      end
    end

    class StyledLineExpectation___ < StringBasedExpectation__

      def initialize chunks, m, sym
        @chunks = chunks
        super m, sym
      end

      # #this-dichotomy

      def _actual_string_matches_expected_string_
        _actual_line = @actual_emission.string
        act_st = Home_::CLI::Styling::ChunkStream_via_String[ _actual_line ]
        exp_st = Stream_[ @chunks ]
        @_assert = :__assert_first
        ok = true
        begin
          exp_x = exp_st.gets
          act_x = act_st.gets
          exp_x || act_x || break
          ok = _assert act_x, exp_x
        end while ok
        ok
      end

      def _assert act_x, exp_x
        send @_assert, act_x, exp_x
      end

      def __assert_first act_s, exp_s
        if _mixed_values_match act_s, exp_s
          @_assert = :__assert_normally ; true
        end
      end

      def __assert_normally act, exp
        if exp
          if act
            ok = _mixed_values_match act.string, exp.fetch(0)
            if ok
              styles = exp.fetch 1
              styles.respond_to? :each_with_index or styles = [styles]
              _mixed_values_match act.styles, styles
            else
              ok
            end
          else
            _will_say_not_same act, exp
          end
        else
          _will_say_not_same [act.string, act.styles], exp
        end
      end

      def _mixed_values_match act_x, exp_x
        if act_x == exp_x
          ACHIEVED_
        else
          _will_say_not_same act_x, exp_x
        end
      end

      def _will_say_not_same act_x, exp_x
        @_act_x = act_x ; @_exp_x = exp_x
        @_say = :__say_not_same_mixed ; false
      end

      def _say_actual_string_does_not_match_expected_string_
        send @_say
      end

      def __say_not_same_mixed
        say = -> x do
          x ? x.inspect : "no more chunks"
        end
        _say_expected_this_had_that_ say[ @_exp_x ], say[ @_act_x ]
      end
    end

    class ExactStringBasedExpectation__ < StringBasedExpectation__

      def initialize x, m, sym
        super m, sym
        yield self if block_given?
        @string = x
      end
    end

    class ExactStringBasedAssertion__ < StringBasedAssertion__

      def _actual_string_matches_expected_string_
        @actual_emission.string == @string
      end

      def _say_expectation_preterite_infinitive_
        @string.inspect
      end

      def _inspectable_
        @string
      end
    end

    class BlankLineExpectation___ < StringBasedExpectation__

      def initialize(*)
        super
        @_say = :__say_normally
      end

      def _actual_string_matches_expected_string_
        s = @actual_emission.string
        if s
          if s.length.zero?
            @_say = :__say_eek
            # (A) we don't remember if we're allowed to change state like
            # this in an expectation. (B) this makes it really strict.
          end
          UNABLE_
        else
          ACHIEVED_
        end
      end

      def _say_expectation_preterite_infinitive_
        send @_say
      end

      def __say_normally
        "to be a blank line"
      end

      def __say_eek
        "to be a blank line (as NIL)"
      end

      def _inspectable_
        NIL
      end
    end

    class RegexpBasedStringExpectation__ < StringBasedExpectation__

      def initialize x, m, sym
        super m, sym
        @regexp = x
      end
    end

    RegexpBasedStringAssertion__ = RegexpBasedStringExpectation__

    class RegexpBasedStringAssertion__ < StringBasedAssertion__

      def _actual_string_matches_expected_string_
        @regexp =~ @actual_emission.string
      end

      def _say_expectation_preterite_infinitive_

        buff = ""
        d = @regexp.options
        o = ::Regexp
        ( d & o::IGNORECASE ).zero? or buff << "i"
        ( d & o::MULTILINE ).zero? or buff << "m"
        ( d & o::EXTENDED ).zero? or buff << "x"
        # FIXEDENCODING / NOENCODING is ignored

        "to match /#{ @regexp.source }/#{ buff }"
      end

      def _inspectable_
        @regexp
      end
    end

    class ProcForLineBasedExpectation___

      def initialize p, m, sym
        @method_name = m
        @proc = p
        @serr_or_sout = sym
      end

      def assert_against_under em, tc
        ProcForLineBasedAssertion___.new( em, @proc, @method_name, @serr_or_sout, tc ).execute
      end

      def is_multi_emission_expectation
        false
      end
    end

    class ProcForLineBasedAssertion___ < MethodAndStreamAssertion__

      def initialize ae, p, m, sym, tc
        @actual_emission = ae
        @proc = p
        @method_name = m
        @serr_or_sout = sym
        @test_context = tc
      end

      def execute
        super
        @proc[ @actual_emission.string ]
      end
    end

    class StringBasedExpectation__

      def initialize m, sym
        @method_name = m
        @serr_or_sout = sym
      end

      alias_method :__init_string_based_expectation, :initialize

      def assert_against_under act, tc
        # ..
        @actual_emission = act
        @test_context = tc
        execute
      end

      def inspect_expectation
        [ _inspectable_, @method_name, @serr_or_sout ].inspect
      end

      def is_multi_emission_expectation
        false
      end
    end

    class StringBasedAssertion__ < MethodAndStreamAssertion__

      def execute
        super
        if ! _actual_string_matches_expected_string_
          fail_say _say_actual_string_does_not_match_expected_string_
        end
      end

      def _say_actual_string_does_not_match_expected_string_
        _say_expected_this_had_that_(
          _say_expectation_preterite_infinitive_,
          @actual_emission.string.inspect,
        )
      end

      def _say_expected_this_had_that_ exp_s, act_s
        "expected #{ exp_s }. had: #{ act_s }"
      end
    end

    class ResuableMethodAndStreamAssertion___ < MethodAndStreamAssertion__

      def initialize m, serr_or_sout
        @method_name = m
        @serr_or_sout = serr_or_sout
      end

      attr_writer(
        :actual_emission,
      )
    end

    class MethodAndStreamAssertion__

      def execute
        if @actual_emission.stream_is_OK @serr_or_sout
          if ! __actual_method_name_matches_expected_method_name
            __fail_because_actual_method_name_does_not_match_expected_method_name
          end
        else
          __fail_because_actual_stream_does_not_match_expected_stream
        end
      end

      # ~

      def __fail_because_actual_stream_does_not_match_expected_stream
        fail_say "expected emission on #{ @serr_or_sout }, #{
          }was on #{ @actual_emission.serr_or_sout }: #{
           }#{ say_all_but :serr_or_sout }"
      end

      # ~

      def __actual_method_name_matches_expected_method_name
        @actual_emission.method_name == @method_name
      end

      def __fail_because_actual_method_name_does_not_match_expected_method_name
        fail_say "expected emission to use #{ @method_name }, #{
          }used #{ @actual_emission.method_name }: #{
           }#{ say_all_but :method_name }"
      end

      # ~

      # --

      def say_all_but sym
        a = [ _inspectable_ ]
        sym_a = %i( method_name serr_or_sout )
        d = sym_a.index sym
        sym_a[ d, 1 ] = EMPTY_A_
        sym_a.each do |sym_|
          a.push instance_variable_get "@#{ sym_ }"
        end
        a.inspect
      end

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__
    end

    # ==

    Want_nothing_on__ = -> do

      h = {}

      want_nothing = -> s, method_name, stream_sym do
        _msg = "was not expecting anything on '#{ stream_sym }' #{
          } (had: #{ [ s, method_name, stream_sym ].inspect })"
        raise ExpectationFailure__, _msg
      end

      -> sym do
        h.fetch sym do
          x = StreamSpy__.define do |o|
            o.serr_or_sout = sym
            o.receive_by = want_nothing
          end
          h[ sym ] = x
          x
        end
      end
    end.call

    SoutSpy__ = Lazy_.call do
      StreamSpy__.define do |o|
        o.serr_or_sout = :sout
      end
    end

    SerrSpy__ = Lazy_.call do
      StreamSpy__.define do |o|
        o.serr_or_sout = :serr
      end
    end

    class StreamSpy__ < Common_::SimpleModel

      def dup_by
        otr = dup
        yield otr
        otr
      end

      def receive_by= p
        @stream_proxy = StreamProxy___.new p, @serr_or_sout
        p
      end

      attr_writer(
        :serr_or_sout,
      )

      attr_reader(
        :stream_proxy,
        :serr_or_sout,
      )
    end

    # ==

    class SingleStreamProxy___

      # simplified, single-stream variant of above

      def initialize & p
        @_receive = p
      end

      def puts s=nil
        @_receive[ s, :puts ]
        NIL
      end

      def << s
        @_receive[ s, :<< ]
      end
    end

    # ==

    class StreamProxy___

      # #[#sy-039.1] one of many such proxies, the subject was the
      # inspiration the current favorite (in remote), but is kept intact
      # here for now..

      def initialize p, k
        @_receive = p
        @_stream_symbol = k
      end

      def puts s=nil
        @_receive[ s, :puts, @_stream_symbol ]
        NIL
      end

      def << s
        @_receive[ s, :<<, @_stream_symbol ]
      end
    end

    # ==

    ExpectationFailure__ = ::Class.new ::RuntimeError  # publicize whenver if you really want to

    Result___ = ::Struct.new :exitstatus

    # ==
  end
end
# :#this-dichotomy is explained at [#here.B]
