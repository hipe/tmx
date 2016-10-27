module Skylab::TestSupport::TestSupport

  module Slowie

    module Fail_Fast

      def self.[] tcc
        tcc.include self
      end

      def call * x_a
        ( @slowie_case ||= Case__.new ).receive_call x_a
      end

      def expect * chan, & recv_msg
        _exp = EmissionExpectation___.new recv_msg, chan
        @slowie_case.receive_emission_expectation _exp
        NIL
      end

      def expect_result x
        _flush_slowie_assertion.execute_expecting_result_of x
      end

      def _flush_slowie_assertion
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

      def receive_emission_expectation ee
        @ee_array.push ee ; nil
      end

      def to_assertion_under tc
        CaseAssertion___.new tc, self
      end

      attr_reader(
        :call_array,
        :ee_array,
      )
    end

    # ==

    class CaseAssertion___

      def initialize tc, cse
        @call_array = cse.call_array
        @ee_array = cse.ee_array
        @test_context = tc
      end

      def execute_expecting_result_of x

        __send_call_and_assert_emission_expectations
        __expect_result_of_call_equals x
      end

      def __send_call_and_assert_emission_expectations

        do_debug = @test_context.do_debug
        if do_debug
          debug_IO = @test_context.debug_IO
        end

        _em_a = remove_instance_variable :@ee_array
        scn = Common_::Polymorphic_Stream.via_array _em_a

        _x_a = remove_instance_variable :@call_array
        @_user_x = @test_context.subject_API.call( * _x_a ) do |*x_a, & em_p|

          if do_debug
            debug_IO.puts x_a.inspect
          end

          ae = ActualEmission___.new em_p, x_a

          if scn.no_unparsed_exists
            fail AssertionFailed, ae.say_extra_emission
          else
            _ee = scn.gets_one
            _ee.execute_assertion_of_under ae, @test_context
            :_ts_unreliable_
          end
        end

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

            _expag = @test_context.expression_agent
            _msg_a = _expag.calculate [], & @actual_emission.emission_proc
            @receive_payload[ _msg_a ]

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
    end

    # ==

    def self.[] tcc
      tcc.include self
    end

    # -
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
