require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] eventpoint - effecting imperative and optional formal transitions" do

    TS_[ self ]
    use :memoizer_methods
    use :eventpoint

    it "graph builds" do
      graph_ || fail
    end

    it "agent with only passive transitions builds" do
      _agent_one || fail
    end

    it "agent with only one active transition builds" do
      _agent_two || fail
    end

    shared_subject :graph_ do

      define_graph_ do |o|

        o.add_state :A,
          :can_transition_to, [ :B ]

        o.add_state :B,
          :can_transition_to, [ :C, :D ]

        o.add_state :C,
          :can_transition_to, [ :D ]

        o.add_state :D

        o.beginning_state :A
      end
    end

    shared_subject :_agent_one do
      define_agent_ do |o|
        o.can_transition_from_to :A, :B
        o.can_transition_from_to :B, :C
        o.can_transition_from_to :C, :D
      end
    end

    shared_subject :_agent_two do
      define_agent_ do |o|
        o.must_transition_from_to :B, :D
      end
    end

    it "profile 1 alone completes a path" do
      # -

        _path = find_path_by_ do |o|

          o.add_pending_task :_task_that_uses_profile_1_, _agent_one
        end

        steps = _path.steps

        steps.length == 3 || fail
        no = steps.detect do |step|
          :_task_that_uses_profile_1_ != step.mixed_task_identifier
        end
        no && fail
      # -
    end

    it "profile 2 alone won't reach an endpoint" do

      _em = expect_failure_and_emission_when_find_path_by_ do |o|

        o.add_pending_task :_task_that_uses_profile_2_, _agent_two
      end

      _em.to_black_and_white_line ==
       "the only pending execution does not bring the system #{
         }from the A state to a finished state" or fail
    end

      it "but SOMETHING MAGICAL happens when they are together" do

        _path = find_path_by_ do |o|

          o.add_pending_task :_task_that_uses_profile_1_, _agent_one
          o.add_pending_task :_task_that_uses_profile_2_, _agent_two
        end

        steps = _path.steps
        steps.length == 2 || fail
        steps.first.mixed_task_identifier == :_task_that_uses_profile_1_ || fail
        steps.last.mixed_task_identifier == :_task_that_uses_profile_2_ || fail
      end
  end
end
# #history: first half of major rewrite
