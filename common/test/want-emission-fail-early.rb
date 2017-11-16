module Skylab::Common::TestSupport

  module Want_Emission_Fail_Early  # [#065]:"future want vs. want event"

    # (this is a would-be replacement for the legacy facility that is
    # in this selfsame file EEK)

    def self.[] tcc
      tcc.include self
    end

    module Legacy
      def self.[] tcc
        Load_legacy___[]
        tcc.include self ; nil
      end
    end

    # -

      # -- (push these to dispatcher if you really have to)

      def only_line_via_this_kind_of_failure * sym_a
        a = lines_via_this_kind_of_failure_via_array sym_a
        1 == a.length || fail
        a.fetch 0
      end

      def lines_via_this_kind_of_failure * sym_a
        lines_via_this_kind_of_failure_via_array sym_a
      end

      def lines_via_this_kind_of_failure_via_array sym_a
        lines = nil
        want_on_channel sym_a do |y|
          lines = y
        end
        x = self.send_subject_call
        x == false or fail __say_not_false( x )
        lines
      end

      def __say_not_false x
        "expected false had #{ x.class }"  # ..
      end

      # --

      def call * x_a
        _EEFE_dispatcher.receive_call x_a
      end

      def call_via_array x_a
        _EEFE_dispatcher.receive_call x_a
      end

      def call_by & p
        _EEFE_dispatcher.receive_call_via_proc p
      end

      def want_emission_fail_early_listener
        _EEFE_dispatcher.listener
      end

      def ignore_emissions_whose_terminal_channel_symbol_is sym
        _EEFE_dispatcher.receive_ignore_etc sym
        NIL
      end

      def want * chan, & recv_msg
        _EEFE_dispatcher.receive_emission_expectation recv_msg, chan
        NIL
      end

      def want_on_channel chan, & recv_msg
        _EEFE_dispatcher.receive_emission_expectation recv_msg, chan
        NIL
      end

      # ~

      def black_and_white ev
        _black_and_white_into_CO "", ev
      end

      def black_and_white_lines ev
        _black_and_white_into_CO [], ev
      end

      def _black_and_white_into_CO y, ev
        _expag = expression_agent
        ev.express_into_under y, _expag
      end

      # --

      def want_result x
        @EEFE_dispatcher.receive_expect_result x, self
      end

      def finish_by & p
        @EEFE_dispatcher.receive_finish_by p, self
      end

      def DEBUG_ALL_BY_FLUSH_AND_EXIT
        @EEFE_dispatcher._DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER_ self
      end

      def execute
        @EEFE_dispatcher.receive_result_as_result self
      end

      def _EEFE_dispatcher
        @EEFE_dispatcher ||= Dispatcher__.new
      end

      def prepare_subject_API_invocation invo
        invo
      end

    # -

    class Spy

      # (if you prefer to keep our instance methods out of your test context)

      def initialize
        @_dispatcher = Dispatcher__.new
      end

      def listener
        @_dispatcher.listener
      end

      def receive_call x_a
        @_dispatcher.receive_call x_a
      end

      def add_ignore_terminal_channel_symbol sym
        @_dispatcher.receive_ignore_etc sym
      end

      def call_by & p
        @_dispatcher.receive_call_via_proc p
      end

      def want * chan, & recv_msg
        @_dispatcher.receive_emission_expectation recv_msg, chan
      end

      def want_emission recv_msg, chan
        @_dispatcher.receive_emission_expectation recv_msg, chan
      end

      def DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER tc
        @_dispatcher._DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER_ tc
      end

      def want_result_under x, tc
        @_dispatcher.receive_expect_result x, tc
      end

      def execute_under tc
        @_dispatcher.receive_result_as_result tc
      end

      def receive_finish_by p, tc
        @_dispatcher.receive_finish_by p, tc
      end
    end

    # ==

    class Dispatcher__

      def initialize

        @listener = -> * x_a, & em_p do
          @_mode_implementation._receive_actual_emission_ em_p, x_a
        end

        @_mode_implementation = ExpectationsRecording___.new
      end

      def receive_call x_a
        @_mode_implementation._receive_call_via_array_ @listener, x_a
      end

      def receive_call_via_proc p
        @_mode_implementation._receive_call_via_proc_ p, listener
      end

      def receive_ignore_etc sym  # [ze]
        @_mode_implementation._receive_ignore_etc_ sym
      end

      def receive_emission_expectation recv_msg, chan
        @_mode_implementation._receive_emission_expectation_ recv_msg, chan
      end

      def receive_expect_result x, tc
        _ = @_mode_implementation._flusher_for_want_result_ x, tc
        _receive_executable_flusher _
      end

      def _DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER_ tc
        _ = @_mode_implementation._flusher_for_DEBUG_AND_EXIT_ tc
        _receive_executable_flusher _
      end

      def receive_finish_by p, tc
        _ = @_mode_implementation._flusher_for_finish_by_ p, tc
        _receive_executable_flusher _
      end

      def receive_result_as_result tc
        _ = @_mode_implementation._flusher_for_result_as_result_ tc
        _receive_executable_flusher _
      end

      def _receive_executable_flusher nu
        @_mode_implementation = nu
        o = nu._EXECUTE_
        @_mode_imlementation = o.mode_implementation
        o.result_value
      end

      attr_reader(
        :listener,
      )
    end

    # ==

    NullImplementations__ = ::Class.new

    class ExpectationsRecording___ < NullImplementations__

      def initialize
        @_any_ignoring_hash = nil
        @_emission_expectations_array = []
        @_one_call_mutex = nil
      end

      def _receive_call_via_array_ listener, x_a
        remove_instance_variable :@_one_call_mutex
        @_expression_of_execution = ArrayBasedExpressionOfExecution___.new listener, x_a
      end

      def _receive_call_via_proc_ p, listener
        remove_instance_variable :@_one_call_mutex
        @_expression_of_execution = ProcBasedExpressionOfExecution___.new p, listener
      end

      def _receive_ignore_etc_ sym
        ( @_any_ignoring_hash ||= {} )[ sym ] = true ; nil
      end

      def _receive_emission_expectation_ recv_msg, chan
        @_emission_expectations_array.push(
          EmissionExpectation___.new( recv_msg, chan ) )
        NIL
      end

      def _flusher_for_DEBUG_AND_EXIT_ tc
        DEBUG_AND_EXIT_Flusher___.new( * _release_these, tc )
      end

      def _flusher_for_want_result_ x, tc
        ValueBasedFlusher___.new x, * _release_these, tc
      end

      def _flusher_for_finish_by_ p, tc
        ProcBasedFlusher___.new p, * _release_these, tc
      end

      def _flusher_for_result_as_result_ tc
        ReturnBasedFlusher__.new( * _release_these, tc )
      end

      def _release_these
        [
          remove_instance_variable( :@_expression_of_execution ),
          remove_instance_variable( :@_any_ignoring_hash ),
          remove_instance_variable( :@_emission_expectations_array ).freeze
        ]
      end

      def _mode_description_
        "recording"
      end
    end

    # ==

    Flusher__ = ::Class.new NullImplementations__

    class DEBUG_AND_EXIT_Flusher___ < Flusher__

      def _EXECUTE_

        x = @expression_of_execution.execute_for_real @test_context
        io = _debug_IO
        io.puts "(RESULT: #{ x.class }"
        io.puts "(GOODBYE FROM [co])"
        exit 0
      end

      def _receive_non_ignored_actual_emission ae

        expag = @test_context.expression_agent
        io = _debug_IO

        ae._express_channel_into_ io
        if ae.emission_looks_like_expression
          ae._express_body_into_under_when_expression_ io, expag
        else
          _ev = ae.emission_proc.call
          _ev.express_into_under io, expag
        end
        NIL
      end

      def _debug_IO
        @test_context.debug_IO
      end
    end

    class ValueBasedFlusher___ < Flusher__  # asserted result against an expected value

      def initialize expected_x, * rest
        @expected_value = expected_x
        super( * rest )
      end

      def _EXECUTE_

        x = @expression_of_execution.execute_for_real @test_context

        if x != @expected_value
          fail AssertionFailed, __say_end_result_is_not( x )
        end

        now_we_are_finished_with_the_execution  # (or before, not sure)

        _final_result_will_be NOTHING_
      end

      def __say_end_result_is_not x
        "for end result, expected #{ Ick_[ @expected_value ] }, had #{ Ick_[ x ] }"
      end
    end

    class ProcBasedFlusher___ < Flusher__  # pass result to a proc before finishing

      def initialize finish_by, * rest
        @finish_with_this_proc = finish_by
        super( * rest )
      end

      def _EXECUTE_

        _x = @expression_of_execution.execute_for_real @test_context

        final_x = @finish_with_this_proc[ _x ]

        now_we_are_finished_with_the_execution

        _final_result_will_be final_x
      end
    end

    class ReturnBasedFlusher__ < Flusher__  # result is merely returned all the way out

      def _EXECUTE_

        x = @expression_of_execution.execute_for_real @test_context

        now_we_are_finished_with_the_execution

        _final_result_will_be x
      end
    end

    # ==

    class ArrayBasedExpressionOfExecution___

      def initialize listener, x_a
        @array = x_a
        @listener = listener
      end

      def execute_for_real tc

        _module_probably = tc.subject_API

        _invo = _module_probably.invocation_via_argument_array @array, & @listener

        _invo = tc.prepare_subject_API_invocation _invo

        _user_x = _invo.execute
        _user_x  # hi.
      end
    end

    class ProcBasedExpressionOfExecution___

      def initialize p, l
        @listener = l
        @proc = p
      end

      def execute_for_real tc

        # experiment - if the proc takes one argument, assume it is for the
        # listener. this also assumes we are not in "spy" mode but in fully
        # integrated mode (where the library has been pulled in to test context)

        if 1 == @proc.arity
          _user_x = @proc.call @listener
        else
          _user_x = @proc.call
        end
        _user_x  # hi.
      end
    end

    # ==

    class Flusher__ < NullImplementations__

      def initialize expression_of_execution, any_ignore_h, exp_em_a, tc

        defined_ignore_h = tc.ignore_emissions_whose_terminal_channel_is_in_this_hash

        _use_ignore_h = if any_ignore_h
          if defined_ignore_h
            self._NOT_YET_DESIGNED__which_to_ignore_when_you_have_both__
          else
            any_ignore_h
          end
        else
          defined_ignore_h || MONADIC_EMPTINESS_
        end

        exp_em_a.frozen? || self._NO
        @expected_emission_scanner = Home_::Scanner.via_array exp_em_a

        @do_ignore_terminal_channel = _use_ignore_h
        @expression_of_execution = expression_of_execution
        @test_context = tc
      end

      def _receive_actual_emission_ em_p, chan

        # (the center)

        if @do_ignore_terminal_channel[ chan.last ]

          if @test_context.do_debug
            @test_context.debug_IO.puts "(ignored: #{ chan.inspect })"
          end

        else

          _ae = ActualEmission___.new em_p, chan

          _receive_non_ignored_actual_emission _ae
        end

        :_co_unreliable_
      end

      def _receive_non_ignored_actual_emission ae

        if @test_context.do_debug
          @test_context.debug_IO.puts ae.channel_symbol_array.inspect
        end
        # -

          if @expected_emission_scanner.no_unparsed_exists
            fail AssertionFailed, __say_extra_emission( ae )
          else
            _ee = @expected_emission_scanner.gets_one
            _ee.execute_assertion_of_under ae, @test_context
          end
        # -
        NIL
      end

      def __say_extra_emission ae
        y = ""
        y << "unexpected emission: #{ ae.channel_symbol_array.inspect }"
        _expag = @test_context.expression_agent
        ae.__maybe_express_first_line_of_expression_into_under_ y, _expag
      end

      def now_we_are_finished_with_the_execution
        if ! @expected_emission_scanner.no_unparsed_exists
          raise AssertionFailed, @expected_emission_scanner.head_as_is.say_missing_emission
        end
      end

      def _final_result_will_be final_x

        o = ResultAndNewImplementation___.new
        o.result_value = final_x
        o.mode_implementation = FinishedImplementation__.instance
        o
      end

      ResultAndNewImplementation___ = ::Struct.new :mode_implementation, :result_value

      def _mode_description_
        "running-the-execution"
      end

      # •

      class ActualEmission___

        # (#open it would probably be prudent to use [#003.2] for this instead..)

        def initialize em_p, x_a
          @channel_symbol_array = x_a
          @emission_proc = em_p
        end

        def __maybe_express_first_line_of_expression_into_under_ y, expag
          if emission_looks_like_expression
            _first_N_lines_HACKISHLY_under 1, expag do |line|
              y << "  (first line: #{ line.inspect })"
            end
          end
          y
        end

        def express_into_under_debuggingly y, expag  # [tm]
          _express_channel_into_ y
          if emission_looks_like_expression
            _express_body_into_under_when_expression_ y, expag
          end
          y
        end

        def _express_channel_into_ y
          y << "#{ @channel_symbol_array.inspect }#{ NEWLINE_ }"
        end

        def _express_body_into_under_when_expression_ y, expag
          _first_N_lines_HACKISHLY_under( -1, expag ) do |line|
            y << "  #{ line.inspect }#{ NEWLINE_ }"
          end
        end

        def _first_N_lines_HACKISHLY_under n, expag  # assume expression

          if n.nonzero?

            count = 0

            _y = ::Enumerator::Yielder.new do |line|
              yield line
              count += 1
              if n == count
                throw :EEK_co_
              end
            end

            catch :EEK_co_ do
              expag.calculate _y, & @emission_proc
            end
          end
          NIL
        end

        def emission_looks_like_expression  # [tm]
          Looks_like_expression__[ @channel_symbol_array ]
        end

        attr_reader(
          :channel_symbol_array,
          :emission_proc,
        )
      end

      # •
    end

    # ==

    class EmissionExpectation___

      def initialize recv_msg, chan
        @channel_symbol_array = chan
        @receive_payload = recv_msg
      end

      def execute_assertion_of_under ae, tc

        EmissionAssertion___.new(
          ae, tc, @receive_payload, @channel_symbol_array
        ).execute
      end

      def say_missing_emission
        "had no more emissions but was expecting: #{ @channel_symbol_array.inspect }"
      end
    end

    class EmissionAssertion___

      def initialize ae, tc, recv_msg, i_a
        @actual_emission = ae
        @channel_symbol_array = i_a
        @receive_payload = recv_msg
        @test_context = tc
      end

      def execute
        if @channel_symbol_array == @actual_emission.channel_symbol_array
          if @receive_payload
            __send_payload
          end
          NIL
        else
          __when_channel_unequal
        end
      end

      def __when_channel_unequal

        @actual_emission.channel_symbol_array.should(
          @test_context.eql @channel_symbol_array )

        if @test_context.respond_to? :see_unexpected_emission
          @test_context.see_unexpected_emission @actual_emission
        end

        fail AssertionFailed
      end

      def __send_payload  # assumes channels are identical (otherwise change this)
        if Looks_like_expression__[ @channel_symbol_array ]
          __send_expression_payload
        else
          __send_event_payload
        end
        NIL
      end

      def __send_event_payload
        _ev = @actual_emission.emission_proc.call
        @receive_payload[ _ev ]
        NIL
      end

      def __send_expression_payload
        _expag = @test_context.expression_agent
        _msg_a = _expag.calculate [], & @actual_emission.emission_proc
        @receive_payload[ _msg_a ]
        NIL
      end
    end

    # ==

    class FinishedImplementation__ < NullImplementations__

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end

      def _mode_description_
        "finished"
      end
    end

    # ==

    class NullImplementations__

      def _receive_call_via_array_ x_a
        _no
      end

      def _receive_call_via_proc_ p, _
        _no
      end

      def _couple_for_listener_
        _no
      end

      def _receive_ignore_etc_ sym
        _no
      end

      def _receive_emission_expectation_ _, _
        _no
      end

      def _flusher_for_want_result_(*)
        _no
      end

      def _flusher_for_result_as_result_(*)
        _no
      end

      def _receive_actual_emission_( * )
        fail "cannot receive emission because you are in #{ _mode_description_ } mode"
      end

      def _no
        _loc = caller_locations( 3, 1 ).fetch 0  # EEEEEEEEK
        fail "cannot `#{ _loc.label }` because you are in #{ _mode_description_ } mode"
      end
    end

#==FROM
    Load_legacy___ = Lazy_.call do

      module Legacy

    def future_expect * a, & p
      add_future_expect a, & p
    end

    def future_expect_only * a, & p
      add_future_expect a, & p
      future_expect_no_more
    end

    def add_future_expect a, & p
      a.push p
      ( @_future_expect_queue ||= [] ).push a ; nil
    end

    def future_expect_no_more
      ( @_future_expect_queue ||= [] ).push false ; nil
    end

    def past_expect_eventually * i_a, & ev_p

      em_a = past_emissions.all_on_channel i_a
      case 1 <=> em_a.length
      when 0
        em = em_a.fetch 0
        if ev_p
          Assert_procs__[ em.event_proc, em.category, ev_p ]
        else
          em
        end
      when -1
        fail Say_expected_one_thing_had_many_things__[ i_a, em_a.length ]
      else
        _x = past_emissions.mixed_for_description
        fail Say_expected_one_thing_had_another_thing__[ i_a, _x ]
      end
    end

    def fut_p

      exp_st = _future_stream

      -> * act_a, & act_p do

        if do_debug
          debug_IO.puts "(#{ act_a.inspect })"
        end

        if exp_st.unparsed_exists
          exp_a = exp_st.gets_one
          if exp_a
            Assert__[ act_p, act_a, exp_a.pop, exp_a ]  # yes eew
          else
            fail Say_expected_nothing_has_something__[ act_a ]
          end
        else
          # when no unparsed exists and above didn't trigger, ignore event
        end

        false  # if client depends on this, it shouldn't
      end
    end

    def future_is_now

      st = _future_stream
      if st.unparsed_exists
        a = st.gets_one
        if a
          a.pop
          fail Say_expect_something_had_nothing__[ a ]
        end
      end
    end

    def _future_stream
      @___future_stream ||= __build_future_stream
    end

    def __build_future_stream

      a = _future_expect_queue
      if a
        Home_::Scanner.via_array a
      else
        Home_::THE_EMPTY_SCANNER
      end
    end

    attr_reader :_future_expect_queue

    def future_black_and_white ev

      a = ev.express_into_under [], future_expression_agent_instance
      a.join '//'
    end

    alias_method :past_black_and_white, :future_black_and_white

    def future_expression_agent_instance
      Home_.lib_.brazen::API.expression_agent_instance
    end

    # ~ public models

    Event_Record = ::Struct.new :category, :event_proc

    class Emissions

      def initialize bx
        @_bx = bx
      end

      def only_on * i_a
        em_a = all_on_channel i_a
        case 1 <=> em_a.length
        when 0   ; em_a.fetch( 0 )
        when -1  ; fail __say_none( i_a )
        else     ; fail __say_many( em_a.length, i_a )
        end
      end

      def __say_none i_a
        _say "had none expected some", i_a
      end

      def __say_many d, i_a
        _say "expected one had #{ d }", i_a
      end

      def _say i_a
        " on #{ i_a.inspect }"
      end

      def all_on_channel i_a

        @_bx.fetch i_a do
          EMPTY_A_
        end
      end

      def mixed_for_description  # [co]
        @_bx.a_
      end
    end

    # ~ support

    Assert__ = -> act_p, act_a, exp_p, exp_a do

      if exp_a == act_a
        if exp_p
          Assert_procs__[ act_p, act_a, exp_p ]
        end
      else
        fail Say_expected_one_thing_had_another_thing__[ exp_a, act_a ]
      end
    end

    Assert_procs__ = -> act_p, act_a, exp_p do

      if Looks_like_expression__[ act_a ]
        exp_p[ Build_lines___[ & act_p ] ]
      else
        exp_p[ act_p[] ]
      end
    end

    Build_lines___ = -> & p do

      _expag = Home_.lib_.brazen::API.expression_agent_instance

      _expag.calculate [], & p

    end

    Say_expect_something_had_nothing__ = -> a do
      "expected #{ a.inspect }, had no more events"
    end

    Say_expected_nothing_has_something__ = -> a do
      "expected no more events, had #{ a.inspect }"
    end

    Say_expected_one_thing_had_another_thing__ = -> exp_a, act_a do
      "expected #{ exp_a.inspect } had #{ act_a.inspect }"
    end

    Say_expected_one_thing_had_many_things__ = -> exp_a, d do
      "expected 1 had #{ d } of #{ exp_a.inspect }"
    end
      end  # end Legacy module
    end  # end lazy
#==TO

    # ==

    Ick_ = -> do
      p = -> x do
        p = Home_.lib_.basic::String.via_mixed.to_proc
        p[ x ]
      end
      -> x do
        p[ x ]
      end
    end.call

    # ==

    Looks_like_expression__ = -> chan do
      :expression == chan[ 1 ]  # be :+[#br-023] aware
    end

    # ==

    AssertionFailed = ::Class.new ::RuntimeError

    # ==

    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  end
end
# #history: one rewrite of this abstracted from [ts] "slowie"
