module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI::Fail_Early

    def self.[] tcc
      tcc.include self
    end

    # -

      def invoke * argv
        _ze_niCLI_client.invoke_via_argv argv
      end

      def invoke_via_argv argv
        _ze_niCLI_client.invoke_via_argv argv
      end

      def expect_empty_puts
        @ze_niCLI_client.expect nil
      end

      def expect_line_by m=nil, & p
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_line_by( & p )
      end

      def expect_each_on_stdout_by m=nil, & p
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_each_on_stdout_by( & p )
      end

      def expect_each_by m=nil, & p
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_each_by( & p )
      end

      def expect_on_stderr_lines_in_big_string m=nil, big_s
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_on_stderr_lines_in_big_string big_s
      end

      def expect_on_stdout_lines_in_big_string m=nil, big_s
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_on_stdout_lines_in_big_string big_s
      end

      def expect_lines_in_big_string m=nil, big_s
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_lines_in_big_string big_s
      end

      def expect_on_stderr m=nil, exp_x
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_on_stderr exp_x
      end

      def expect_on_stdout m=nil, exp_x
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect_on_stdout exp_x
      end

      def expect m=nil, exp_x
        m and @ze_niCLI_client.using_method m
        @ze_niCLI_client.expect exp_x
      end

      def expect_failed
        @ze_niCLI_client.expect_failed_under self
      end

      def expect_succeeded
        @ze_niCLI_client.expect_succeeded_under self
      end

      def _ze_niCLI_client
        @ze_niCLI_client ||= Client_for_Expectations_of_Invocation.new
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

      def using_method m
        @_method = m ; nil
      end

      def on_stream serr_or_sout
        @_stream = serr_or_sout ; nil
      end

      def invoke * argv
        invoke_via_argv argv
      end

      def invoke_via_argv argv
        @_setup.ARGV = argv ; nil
      end

      def expect_line_by & p
        __add_proc_for_line_based_expectation p
      end

      def expect_each_on_stdout_by & p
        @_stream = :sout
        _add_proc_based_expectation p
      end

      def expect_each_by & p
        _add_proc_based_expectation p
      end

      def expect_on_stderr_lines_in_big_string big_s
        @_stream = :serr
        _add_big_string_based_expectation big_s
      end

      def expect_on_stdout_lines_in_big_string big_s
        @_stream = :sout
        _add_big_string_based_expectation big_s
      end

      def expect_lines_in_big_string big_s
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

      def expect_on_stderr exp_x
        @_stream = :serr
        _add_line_based_expectation exp_x
      end

      def expect_on_stdout exp_x
        @_stream = :sout
        _add_line_based_expectation exp_x
      end

      def expect m=nil, exp_x
        @_method = m if m
        _add_line_based_expectation exp_x
      end

      def _add_line_based_expectation exp_x

        @_setup.add_line_based_expectation exp_x, @_method, @_stream
        NIL
      end

      def expect_failed_under tc
        _invocation_under( tc ).execute.__expect_failed
      end

      def expect_succeeded_under tc
        _invocation_under( tc ).execute.__expect_succeeded
      end

      def _invocation_under tc
        InvocationUnderExpectations__.new @_setup, tc
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
        @_exitstatus = @_CLI.execute
        remove_instance_variable( :@_spy ).finished_invoking_notify
        self
      end

      # ~

      def __expect_failed
        if @_exitstatus.zero?
          __when_exitstatus_zero
        end
      end

      def __when_exitstatus_zero
        fail_say "expected nonzero exitstatus, had zero"
      end

      # ~

      def __expect_succeeded
        if @_exitstatus.nonzero?
          __when_exitstatus_nonzero
        end
      end

      def __when_exitstatus_nonzero
        fail_say "expected zero exitstatus, had #{ @_exitstatus }"
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
          kn.value_x
        else
          __program_name_string_array
        end

        spy = Spy___.new setup, tc

        cli = classish.new(
          argv,
          :_ze_NO_,
          spy.sout_stream_proxy,
          spy.serr_stream_proxy,
          _pn_s_a,
        )

        if classish_came_from_test_context
          tc.prepare_CLI cli
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

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__
    end

    # ==

    class Spy___

      def initialize setup, tc

        a = setup.expectations
        if ! a
          self._NO_PROBLEM_just_use_empty_a
        end

        @_expectations_queue = Common_::Polymorphic_Stream.via_array a

        @do_debug = tc.do_debug
        if @do_debug
          @debug_IO = tc.debug_IO
        end

        has = setup.has

        _sout_spy = if has[ :sout ]
          SoutSpy__[].new do |o|
            o.receive = method :_receive
          end
        else
          Expect_nothing_on__[ :sout ]
        end

        _serr_spy = if has[ :serr ]
          SerrSpy__[].new do |o|
            o.receive = method :_receive
          end
        else
          Expect_nothing_on__[ :serr ]
        end

        @_is_using_multi_emission_assertion = false
        @_sout_spy = _sout_spy
        @_serr_spy = _serr_spy
        @_receive = :_receive_emission_normally
        @test_context = tc
      end

      def _receive s, method_name, stream_sym

        act = ActualEmission___.new s, method_name, stream_sym

        if @do_debug
          act.express_debugging_into @debug_IO
        end

        send @_receive, act
        NIL
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
        end
        NIL
      end

      def finished_invoking_notify

        if @_is_using_multi_emission_assertion

          @_multi_emission_assertion.finished_invoking_notify
          remove_instance_variable :@_multi_emission_assertion
        end

        remove_instance_variable :@_is_using_multi_emission_assertion
        remove_instance_variable :@_receive

        if ! @_expectations_queue.no_unparsed_exists
          __when_missing_emission
        end
      end

      def __when_missing_emission
        _exp = @_expectations_queue.current_token
        fail_say "actual output ended when expecting: #{ _exp.inspect_expectation }"
      end

      define_method :fail_say, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_SAY__

      # -- simple readers

      def serr_stream_proxy
        @_serr_spy.stream_proxy
      end

      def sout_stream_proxy
        @_sout_spy.stream_proxy
      end
    end

    # ==

    class ActualEmission___

      def initialize s, m, sym
        @method_name = m
        @serr_or_sout = sym
        @string = s
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

    # ==

    class Setup___

      def initialize
        @expectations = []
        @has = {}
      end

      def program_name_string_array= x
        @program_name_string_array_knownness = Common_::Known_Known[ x ]
        x
      end

      def add_proc_based_expectation p, m, serr_or_sout
        _add ProcBasedExpectation__.new( p, m, serr_or_sout ), serr_or_sout
      end

      def add_big_string_based_expectation big_s, m, serr_or_sout
        _add BigStringBasedExpectation__.new( big_s, m, serr_or_sout ), serr_or_sout
      end

      def add_line_based_expectation exp_x, method_name, serr_or_sout
        _add String_based_expectation___[ exp_x, method_name, serr_or_sout ], serr_or_sout
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
        :subject_CLI_by,
      )

      attr_reader(
        :ARGV,
        :has,
        :expectations,
        :program_name_string_array_knownness,
        :subject_CLI_by,
      )
    end

    # == (forward declarations)

    MethodAndStreamAssertion__ = ::Class.new

    StringBasedAssertion__ = ::Class.new MethodAndStreamAssertion__

    StringBasedExpectation__ = StringBasedAssertion__  # #for-now

    ExactStringBasedExpectation__ = ::Class.new StringBasedExpectation__

    ExactStringBasedAssertion__ = ExactStringBasedExpectation__  # #for-now

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

        @_stream = Home_.lib_.basic::String.line_stream remove_instance_variable :@big_string

        @_reusable_assertion = ReusableExactStringBasedAssertion__.new :puts, @serr_or_sout, @test_context

        line = @_stream.gets
        line || self._NO
        line.chop!  # live dangerously
        @_reusable_assertion.string = line

        @_receive = :__receive
        send @_receive, em
      end

      def __receive em

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

    String_based_expectation___ = -> x, m, sym do
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

    class ExactStringBasedExpectation__ < StringBasedExpectation__

      def initialize x, m, sym
        @string = x
        super m, sym
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

      def _actual_string_matches_expected_string_
        ! @actual_emission.string
      end

      def _say_expectation_preterite_infinitive_
        "to be a blank line"
      end

      def _inspectable_
        EMPTY_S_
      end
    end

    class RegexpBasedStringExpectation__ < StringBasedExpectation__

      def initialize x, m, sym
        @regexp = x
        super m, sym
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
        NIL
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
          __fail_because_actual_string_does_not_match_expected_string
        end
      end

      def __fail_because_actual_string_does_not_match_expected_string

        fail_say "expected #{ _say_expectation_preterite_infinitive_ }. had: #{
          }#{ @actual_emission.string.inspect }"
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
        if __actual_stream_matches_expected_stream
          if ! __actual_method_name_matches_expected_method_name
            __fail_because_actual_method_name_does_not_match_expected_method_name
          end
        else
          __fail_because_actual_stream_does_not_match_expected_stream
        end
      end

      # ~

      def __actual_stream_matches_expected_stream
        @actual_emission.serr_or_sout == @serr_or_sout
      end

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
        sym_a = %i( method_name, serr_or_sout )
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

    Expect_nothing_on__ = -> do

      h = {}

      expect_nothing = -> s, method_name, stream_sym do
        _msg = "unexpected: #{ [ s, method_name, stream_sym ].inspect }"
        raise ExpectationFailure__, _msg
      end

      -> sym do
        h.fetch sym do
          x = StreamSpy__.new do |o|
            o.serr_or_sout = sym
            o.receive = expect_nothing
          end
          h[ sym ] = x
          x
        end
      end
    end.call

    SoutSpy__ = Lazy_.call do
      StreamSpy__.new do |o|
        o.serr_or_sout = :sout
      end
    end

    SerrSpy__ = Lazy_.call do
      StreamSpy__.new do |o|
        o.serr_or_sout = :serr
      end
    end

    class StreamSpy__

      def initialize
        yield self
        freeze
      end

      def new
        otr = dup
        yield otr
        otr
      end

      def receive= p
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

    class StreamProxy___

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
