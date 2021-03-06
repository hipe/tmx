require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] eventpoint - effecting optional formal transitions" do

    # (NOTE the bulk of this appears that it was linguistic goofing off)

    TS_[ self ]

    use :memoizer_methods
    use :eventpoint

    it "graph builds" do
      graph_ || fail
    end

    shared_subject :graph_ do

      define_graph_ do |o|
        o.add_state :A, :can_transition_to, :B
        o.add_state :B
        o.beginning_state :A
      end
    end

    same_inf = "transition from the state you are in, which is the A state."
    same_sing = "transitions from the state you are in, which is the A state."

    context "(empty)" do

      it "against an empty pool" do

        _em = want_failure_and_emission_when_find_path_by_ do |_|
          NOTHING_
        end

        _line = black_and_white_line_of_ _em
        _line == "there are no state transitions so #{
          }nothing brings the system from the A state to a finished state." || fail
      end
    end

    context "(empty agent)" do

      it "empty agent builds" do
        agent_ || fail
      end

      it "reconcile with one dud signature" do

        _em = want_failure_and_emission_when_find_path_by_ do |o|

          o.add_pending_task :_the_empty_agent, agent_
        end

        s_a = black_and_white_lines_of_ _em
        "'_the_empty_agent' requires nothing." == s_a.first || fail
        "it does not #{ same_inf }" == s_a.last || fail
      end

      it "same as above but 2x subjects" do

        _em = want_failure_and_emission_when_find_path_by_ do |o|
          o.add_pending_task :_empty_agent_1, agent_
          o.add_pending_task :_empty_agent_2, agent_
        end

        s_a = black_and_white_lines_of_ _em
        s_a.first == "'_empty_agent_1' and '_empty_agent_2' require nothing." || fail
        s_a.last == "neither of them #{ same_sing }" || fail
      end

      def agent_
        _the_empty_agent
      end
    end

    context "if you use invalid name in your agent profile" do

      it "the agent profile builds (it's separate from the graph)" do
        agent_ || fail
      end

      it "reconcile with bad name signature - key error at recon time" do

        _pool = build_pending_execution_pool_ do |o|
          o.add_pending_task :_invalid_agent_1, agent_
        end

        begin
          find_path_ _pool, graph_
        rescue subject_module_::KeyError => e
        end

        e.message == "unrecognized node 'feeple'. did you mean A or B?" || fail
      end

      def agent_
        _bad_agent
      end
    end

    context "(wrong direction)" do

      it "reconcile with invalid direction - rt at recon time" do

        _pool = build_pending_execution_pool_ do |o|
          o.add_pending_task :_wrong_direction_agent_1, agent_
        end

        begin
          find_path_ _pool, graph_
        rescue subject_module_::RuntimeError => e
        end

        _exp = "'B' cannot transition to 'A'. #{
          }it is an endpoint, and so has no transitions #{
            }(in '_wrong_direction_agent_1')." || fail

        e.message == _exp || fail
      end

      def agent_
        _wrong_direction_agent
      end
    end

    context "(ok)" do

      it "reconcile one nudge - WORKS" do

        _ = find_path_by_ do |o|
          o.add_pending_task :_good_agent_1, agent_
        end
        _.steps.length == 1 || fail
      end

      def agent_
        _good_agent
      end
    end

    context "(ambiguous - multiple agents doing the same thing)" do

      it "reconcile with ambiguous nudges - soft failure" do

        _em = want_failure_and_emission_when_find_path_by_ do |o|
          o.add_pending_task :_beavis_agent, agent_
          o.add_pending_task :_butthead_agent, agent_
        end

        s_a = black_and_white_lines_of_ _em

        s_a[0] == "both '_beavis_agent' and '_butthead_agent' transition to 'B'" || fail
        s_a[1] == "so you can't have both of them at the same time." || fail
      end

      def agent_
        _good_agent
      end
    end

    # ==

    shared_subject :_wrong_direction_agent do
      define_agent_ do |o|
        o.can_transition_from_to :B, :A
      end
    end

    shared_subject :_bad_agent do
      define_agent_ do |o|
        o.can_transition_from_to :feeple, :deeple
      end
    end

    shared_subject :_good_agent do
      define_agent_ do |o|
        o.can_transition_from_to :A, :B
      end
    end

    shared_subject :_the_empty_agent do
      define_agent_ do |o|
        NOTHING_
      end
    end

    # ==

  end
end
# #history: full rewrite of test content (not test stories)
