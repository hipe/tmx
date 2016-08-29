module Skylab::Zerk::TestSupport

  module API

    PUBLIC = true  # [mt]

    Require_ACS_for_testing_[]

    def self.[] tcc

      Use_::Memoizer_methods[ tcc ]
      Use_::Expect_event[ tcc ]
      ACS_.test_support::Expect_Root_ACS[ tcc ]

      tcc.send :define_singleton_method, :call_by, Call_by_method___
      tcc.include self
    end

    # -
      Call_by_method___ = -> & p do
        shared_subject :root_ACS_state do
          instance_exec( & p )
        end
      end
    # -

    # -
      # -- assertions for result

      def fails
        root_ACS_result.should eql Home_::UNABLE_
      end

      def expect_trueish_result
        x = root_ACS_result
        if ! x
          fail "expected trueish result, had #{ x.inspect }"
        end
      end

      def message_  # must be used in conjuction with #here
        root_ACS_state.message
      end

      def raises_argument_error  # must be used in conjuction with #here
        root_ACS_state or fail
      end

      # -- assertion for emission language

      def look_like_did_you_mean_for_ s_a

        _rxs = s_a.map do |s|
          "'#{ s }'"
        end.join ' \| '

        match %r(, expecting \{ #{ _rxs } \}\z)
      end

      # -- assertion for emissions

      def no_such_association_
        :no_such_association
      end

      def past_end_of_phrase_
        :arguments_continued_past_end_of_phrase
      end

      def set_leaf_component_
        :set_leaf_component
      end

      # -- assertion for exceptions

      def first_line
        line 0
      end

      def second_line
        line 1
      end

      def line d
        exception_message_lines.fetch d
      end

      def argument_error_lines & p

        _ev = rescue_argument_error( & p )
        _ev.message.split %r((?<=\n))
      end

      # -- effecting the state

      def rescue_argument_error & p  # is :#here
        begin
          instance_exec( & p )
        rescue ::ArgumentError => e
        end

        if do_debug
          if e
            debug_IO.puts e.inspect
          else
            debug_IO.puts '(no argument error when one was expected)'
          end
        end

        e
      end

      def call * x_a  # result is state

        call_via_iambic x_a
      end

      def call_via_iambic x_a  # result is state

        el = event_log

        _use_oes_p = if el
          el.handle_event_selectively
        else
          Expect_no_events_because_event_log_was_falseish___
        end

        result = zerk_API_call _use_oes_p, x_a

        if instance_variable_defined? :@root_ACS
          _o = remove_instance_variable :@root_ACS
        end

        root_ACS_state_via result, _o
      end

      def zerk_API_call oes_p, x_a  # result is result

        subject_API.call( * x_a, & oes_p )
      end

      # -- hook-outs/ins

      def state_for_expect_event
        root_ACS_state
      end

      define_method :expression_agent_for_expect_event, ( Lazy_.call do
        Home_.lib_.brazen::API.expression_agent_instance
      end )

    # -

    Expect_no_events_because_event_log_was_falseish___ = -> * x_a, & _ev_p do
      fail "no events were expected because `event_log` was false-ish (had: #{ x_a.inpsect })"
    end
  end
end
