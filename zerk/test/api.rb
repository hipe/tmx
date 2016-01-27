module Skylab::Zerk::TestSupport

  module API

    PUBLIC = true  # [mt]

    Require_ACS_for_testing_[]

    def self.[] tcc

      Memoizer_Methods[ tcc ]
      Expect_Event[ tcc ]
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

      # -- effecting the state

      def call * x_a

        if block_given?
          raise ::ArgumentError, ___say_why_no_blocks
        end

        @root_ACS ||= build_root_ACS  # build COLD root ACS

        el = event_log
        if el
          use_oes_p = el.handle_event_selectively
          use_pp = -> _ do
            use_oes_p
          end
        else
          use_pp = No_events_because_etc_pp_
        end

        _x = Home_::API.call x_a, @root_ACS, & use_pp
        _o = remove_instance_variable :@root_ACS

        root_ACS_state_via _x, _o
      end

      def ___say_why_no_blocks
        "isn't the event log's handler what you want?"
      end

      # -- hook-outs/ins

      def state_  # for expect event
        root_ACS_state
      end

      define_method :expression_agent_for_expect_event, ( Lazy_.call do
        Home_.lib_.brazen::API.expression_agent_instance
      end )

    # -

    say_etc = nil

    No_events_because_etc_pp_ = -> * do  # cp from [ac]
      fail say_etc[]
    end

    say_etc = -> do
      "no events were expected because `event_log` was false-ish"
    end
  end
end
