module Skylab::Common::TestSupport

  module Expect_Emission_Fail_Early  # [#065]:"future expect vs. expect event"

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
        expect_on_channel sym_a do |y|
          lines = y
        end
        _x = self.send_subject_call
        _x == false || fail
        lines
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

      def expect_emission_fail_early_listener
        _EEFE_dispatcher.listener
      end

      def ignore_emissions_whose_terminal_channel_symbol_is sym
        _EEFE_dispatcher.receive_ignore_etc sym
        NIL
      end

      def expect * chan, & recv_msg
        _EEFE_dispatcher.receive_emission_expectation recv_msg, chan
        NIL
      end

      def expect_on_channel chan, & recv_msg
        _EEFE_dispatcher.receive_emission_expectation recv_msg, chan
        NIL
      end

      # --

      def expect_result x
        @EEFE_dispatcher.receive_expect_result x, self
      end

      def finish_by & p
        @EEFE_dispatcher.receive_finish_by p, self
      end

      def execute
        @EEFE_dispatcher.receive_result_as_result self
      end

      def _EEFE_dispatcher
        @EEFE_dispatcher ||= Dispatcher__.new
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

      def call_by & p
        @_dispatcher.receive_call_via_proc p
      end

      def expect * chan, & recv_msg
        @_dispatcher.receive_emission_expectation recv_msg, chan
      end

      def execute_under tc
        @_dispatcher.receive_result_as_result tc
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
        @_mode_implementation._receive_call_via_proc_ p
      end

      def expect_emission_fail_early_listener
        nu, x = @_mode_implementation._couple_for_listener_
        nu and @_mode_implementation = nu
        x
      end

      def receive_ignore_etc sym
        @_mode_implementation._receive_ignore_etc_ sym
      end

      def receive_emission_expectation recv_msg, chan
        @_mode_implementation._receive_emission_expectation_ recv_msg, chan
      end

      def receive_expect_result x, tc
        _ = @_mode_implementation._replacement_implementation_for_expect_result_ x, tc
        _receive_executable_replacement_implementation _
      end

      def receive_finish_by p, tc
        _ = @_mode_implementation._replacement_implementation_for_finish_by_ p, tc
        _receive_executable_replacement_implementation _
      end

      def receive_result_as_result tc
        _ = @_mode_implementation._replacement_implementation_for_result_as_result_ tc
        _receive_executable_replacement_implementation _
      end

      def _receive_executable_replacement_implementation nu
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

      def _receive_call_via_proc_ p
        remove_instance_variable :@_one_call_mutex
        @_expression_of_execution = ProcBasedExpressionOfExecution___.new p
      end

      def _receive_ignore_etc_ sym
        ( @_any_ignoring_hash ||= {} )[ sym ] = true ; nil
      end

      def _receive_emission_expectation_ recv_msg, chan
        @_emission_expectations_array.push(
          EmissionExpectation___.new( recv_msg, chan ) )
        NIL
      end

      def _replacement_implementation_for_expect_result_ x, tc
        ValueBasedFlusher___.new x, * _release_these, tc
      end

      def _replacement_implementation_for_finish_by_ p, tc
        ProcBasedFlusher___.new p, * _release_these, tc
      end

      def _replacement_implementation_for_result_as_result_ tc
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

        _user_x = tc.subject_API.call( * @array, & @listener )
        _user_x  # hi.
      end
    end

    class ProcBasedExpressionOfExecution___

      def initialize p
        @proc = p
      end

      def execute_for_real _tc
        _user_x = @proc.call
        _user_x  # #hi.
      end
    end

    # ==

    class Flusher__ < NullImplementations__

      def initialize expression_of_execution, any_ignore_h, exp_em_a, tc

        exp_em_a.frozen? || self._NO
        @expected_emission_scanner = Home_::Polymorphic_Stream.via_array exp_em_a

        @do_ignore_terminal_channel = ( any_ignore_h || MONADIC_EMPTINESS_ )
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

          ae = ActualEmission___.new em_p, chan

          if @test_context.do_debug
            @test_context.debug_IO.puts chan.inspect
          end

          if @expected_emission_scanner.no_unparsed_exists
            fail AssertionFailed, ae.say_extra_emission
          else
            _ee = @expected_emission_scanner.gets_one
            _ee.execute_assertion_of_under ae, @test_context
          end
        end

        :_co_unreliable_
      end

      def now_we_are_finished_with_the_execution
        if ! @expected_emission_scanner.no_unparsed_exists
          raise AssertionFailed, @expected_emission_scanner.current_token.say_missing_emission
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

        def initialize em_p, x_a
          @channel_symbol_array = x_a
          @emission_proc = em_p
        end

        def say_extra_emission
          "unexpected emission: #{ @channel_symbol_array.inspect }"
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
        fail AssertionFailed
      end

      def __send_payload  # assumes channels are identical (otherwise change this)
        if :expression == @channel_symbol_array[ 1 ]
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

      def _receive_call_via_proc_ p
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

      def _replacement_implementation_for_expect_result_(*)
        _no
      end

      def _replacement_implementation_for_result_as_result_(*)
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
        Home_::Polymorphic_Stream.via_array a
      else
        Home_::Polymorphic_Stream.the_empty_polymorphic_stream
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

      if :expression == act_a[ 1 ]  # be :+[#br-023] aware
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

    AssertionFailed = ::Class.new ::RuntimeError

    # ==

    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
    NOTHING_ = nil
  end
end
# #history: one rewrite of this abstracted from [ts] "slowie"
