module Skylab::Zerk::TestSupport

  module API

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

      def set_leaf_component_
        :set_leaf_component
      end

      # -- effecting the state

      def call * x_a

        block_given? and raise ::ArgumentError

        @root_ACS ||= build_root_ACS

        oes_p = event_log.handle_event_selectively
        _pp = -> _ do
          oes_p
        end

        _x = Home_::API.call x_a, @root_ACS, & _pp
        _o = remove_instance_variable :@root_ACS

        root_ACS_state_via _x, _o
      end

      # -- hook-outs/ins

      def state_  # for expect event
        root_ACS_state
      end

      define_method :expression_agent_for_expect_event, ( Lazy_.call do
        Home_.lib_.brazen::API.expression_agent_instance
      end )

    # -
  end
end
