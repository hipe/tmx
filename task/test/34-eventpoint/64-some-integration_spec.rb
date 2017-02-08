require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] eventpoint - some integration" do

    # NOTE this current pass is about restoring old tests. for continuity
    # with the past we are for now keeping the exact same test description
    # strings, even though some concepts have changed (like "profile" not
    # "signature", "pending execution" not "agent")

    TS_[ self ]
    use :memoizer_methods
    use :eventpoint

    it "graph builds" do
      graph_ || fail
    end

    shared_subject :graph_ do

      define_graph_ do |o|

        o.add_state :A,
          :can_transition_to, [ :B, :C ]

        o.add_state :B,
          :can_transition_to, :C

        o.add_state :C

        o.beginning_state :A
      end
    end

      it "sig 2 short-circuits - sig 1 is not happy b.c it needs B" do

        _em = expect_failure_and_emission_when_find_path_by_ do |o|
          o.add_pending_task :_ag1, _pro1_must_B
          o.add_pending_task :_ag2, _pro2B_can_A2C_can_B2C
        end
        _ = _em.to_black_and_white_line
        _ == "'_ag1' relies on the B state and the B state isn't reached." || fail
      end

    context "(context)" do

      it "(this scenario finds a path but..)" do
        _path = __path
        _path.steps.length == 1 || fail
      end

      it "sig 2 short-circuits - sig 3 is ok because it doesn't *NEED* B BUT WHIMPERS!!" do
        _em = __emission
        _ = _em.to_black_and_white_line
        _ == ( ( "'_ag3' will have no effect because the system #{
          }does not reach the B state" )
        ) or fail
      end

      def __path
        _tuple.fetch 0
      end

      def __emission
        _tuple.fetch 1
      end

      shared_subject :_tuple do

        log = build_event_log_

        _pool = build_pending_execution_pool_ do |o|
          o.add_pending_task :_ag2, _pro2B_can_A2C_can_B2C
          o.add_pending_task :_ag3, _pro3_can_B
        end

        path = subject_module_::Path_via_PendingExecutionPool_and_Graph.call_by do |o|
          o.pending_execution_pool = _pool
          o.graph = graph_
          o.say_plugin_by = -> * { TS_._NOT_USED_HERE }
          o.listener = log.handle_event_selectively
        end

        em = log.gets
        log.gets && fail  # whether or not there was one, be sure there's not 2
        [ path, em ]
      end
    end

      it "sig 4 which goes the long way around, satisfies 1 and 3" do

        _path = find_path_by_ do |o|
          o.add_pending_task :_ag1, _pro1_must_B
          o.add_pending_task :_ag2, _pro2_can_A2C_can_B2C
          o.add_pending_task :_ag3, _pro3_can_B
          o.add_pending_task :_ag4, _pro4_must_A2B_can_B2C
        end

        against_path_expect_steps_ _path do
          expect_step_ :_ag4, :A, :B
          expect_step_ :_ag1, :B, :B
          expect_step_ :_ag3, :B, :B
          expect_step_ :_ag2, :B, :C
        end
      end

    shared_subject :_pro1_must_B do
      define_agent_ do |o|
        o.must_transition_from_to :B, :B
      end
    end

    shared_subject :_pro2_can_A2C_can_B2C do
      define_agent_ do |o|
        o.can_transition_from_to :A, :C
        o.must_transition_from_to :B, :C
      end
    end

    shared_subject :_pro2B_can_A2C_can_B2C do
      define_agent_ do |o|
        o.can_transition_from_to :A, :C
        o.can_transition_from_to :B, :C
      end
    end

    shared_subject :_pro3_can_B do
      define_agent_ do |o|
        o.can_transition_from_to :B, :B
      end
    end

    shared_subject :_pro4_must_A2B_can_B2C do
      define_agent_ do |o|
        o.must_transition_from_to :A, :B
        o.can_transition_from_to :B, :C
      end
    end
  end
end
# #history: full rewrite with same stories
