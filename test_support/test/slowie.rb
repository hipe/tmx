module Skylab::TestSupport::TestSupport

  module Slowie

    module Fail_Fast

      def self.[] tcc
        tcc.include self
      end

      def call * x_a
        ( @slowie_case ||= Case__.new ).receive_call x_a
      end

      def ignore_emissions_whose_terminal_channel_symbol_is sym
        @slowie_case.__ignore_etc sym
        NIL
      end

      def expect * chan, & recv_msg
        _exp = EmissionExpectation___.new recv_msg, chan
        @slowie_case.receive_emission_expectation _exp
        NIL
      end

      def expect_result x
        flush_to_case_assertion.execute_expecting_result_of x
      end

      def release_assertion
        remove_instance_variable
      end

      def flush_to_case_assertion
        remove_instance_variable( :@slowie_case ).to_assertion_under self
      end
    end

    # ==

    class Case__

      def initialize
        @__one_call_mutex = nil
      end

      def receive_call x_a
        remove_instance_variable :@__one_call_mutex
        @call_array = x_a
        @ee_array = []
        NIL
      end

      def __ignore_etc sym
        ( @ignore_these_terminal_channel_symbols ||= {} )[ sym ] = true
        NIL
      end

      def receive_emission_expectation ee
        @ee_array.push ee ; nil
      end

      def to_assertion_under tc
        CaseAssertion___.new tc, self
      end

      attr_reader(
        :call_array,
        :ee_array,
        :ignore_these_terminal_channel_symbols,
      )
    end

    # ==

    class CaseAssertion___

      def initialize tc, cse
        @call_array = cse.call_array
        @ee_array = cse.ee_array
        @ignore_these_terminal_channel_symbols = cse.ignore_these_terminal_channel_symbols
        @test_context = tc
      end

      def execute_expecting_result_of expected_x

        @_user_x = flush_to_result
        finish
        __expect_result_of_call_equals expected_x
      end

      def flush_to_result

        channel_symbol_a = nil ; emission_p = nil

        scn = __flush_emission_expectation_scanner

        do_see = -> do

          ae = ActualEmission___.new emission_p, channel_symbol_a

          if @test_context.do_debug
            @test_context.debug_IO.puts channel_symbol_a.inspect
          end

          if scn.no_unparsed_exists
            fail AssertionFailed, ae.say_extra_emission
          else
            _ee = scn.gets_one
            _ee.execute_assertion_of_under ae, @test_context
            :_ts_unreliable_
          end
        end

        ignore_h = @ignore_these_terminal_channel_symbols

        see = if ignore_h
          -> do
            if ignore_h[ channel_symbol_a.last ]
              if @test_context.do_debug
                @test_context.debug_IO.puts "(ignored: #{ channel_symbol_a.inspect })"
              end
              :_ts_unreliable_
            else
              do_see[]
            end
          end
        else
          do_see
        end

        _args = remove_instance_variable :@call_array
        @test_context.subject_API.call( * _args ) do |*i_a, & em_p|
          channel_symbol_a = i_a
          emission_p = em_p
          see[]
        end
      end

      def __flush_emission_expectation_scanner

        _em_a = remove_instance_variable :@ee_array
        scn = Common_::Polymorphic_Stream.via_array _em_a
        @__expected_emission_scanner = scn
        scn
      end

      def finish

        scn = remove_instance_variable :@__expected_emission_scanner

        if ! scn.no_unparsed_exists
          fail AssertionFailed, scn.current_token.say_missing_emission
        end
        NIL
      end

      def __expect_result_of_call_equals x
        if x != @_user_x
          fail AssertionFailed, __say_end_result_is_not( x )
        end
      end

      def __say_end_result_is_not x
        "for end result, expected #{ Ick_[ x ] }, had #{ Ick_[ @_user_x ] }"
      end
    end

    # ==

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

    # ==

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

    def self.[] tcc
      tcc.include self
    end

    # -

      def fails_because_no_test_directories_ sym

        expect :error, :expression, :operation_parse_error, :missing_required_arguments do |y|

          y.first == "can't :#{ sym } without test directories. (maybe use :test_directory.)" || fail
        end

        expect_result UNABLE_
      end

      def subject_API
        Home_::Slowie::API
      end

      def expression_agent
        Home_::Zerk_::API::ArgumentScannerExpressionAgent.instance
      end
    # -

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
  end
end
