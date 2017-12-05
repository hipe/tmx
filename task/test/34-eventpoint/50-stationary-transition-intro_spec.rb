require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] eventpoint - stationary transition intro" do

    # :#coverpoint1.1.1:
    #
    # in a full rearchitecting of an older mechanism it replaces, we offer
    # that the agent profile can express a formal "stationary transition",
    # which is simply a transition from any node back to itself.
    #
    # adding such a transition to a path expends the associated pending
    # execution, but it has no impact on the state machine's state. this
    # sort of formal transition exists only to give the pending execution
    # the ability to say "hey, there is something i can/must do at this
    # node" without saying "i move things from that node to this one myself".
    #
    # it gets interesting because the pending execution must specify this
    # transition as either optional or imperative. if imperative, this says
    # that the pending execution requires that the path pass through the
    # node (but does it does not offer a means of getting there!). so the
    # existence of such a formal transition can impact how the path is made
    # (and whether one is found).
    #
    # the (here we go) optional stationary formal transition, on the other
    # hand, says simply "if you happen to pass through the node along the
    # way, there's something i would do; but if you don't, don't worry
    # about it".

    TS_[ self ]
    use :memoizer_methods
    use :eventpoint

    it "quick visit \"jumps in\" without messing anything up" do

      _path = find_path_by_ do |o|
        o.add_pending_task :_ag_qv, _quick_visit_agent
        o.add_pending_task :_ag_bu, _busy_agent
      end
      _path.steps.length == 3 || fail
    end

    it "same scenario, but the quick visitor is imperative - note they share the node" do

      _path = find_path_by_ do |o|
        o.add_pending_task :_ag_qvi, _imperative_quick_visit_agent
        o.add_pending_task :_ag_bu, _busy_agent
      end
      _path.steps.length == 3 || fail
    end

    it "same scenario, but two quick visitors and particular order" do

      _path = find_path_by_ do |o|
        o.add_pending_task :_ag_qvi_ONE, _imperative_quick_visit_agent
        o.add_pending_task :_ag_bu, _busy_agent
        o.add_pending_task :_ag_qvi_TWO, _imperative_quick_visit_agent
      end

      against_path_expect_steps_ _path do
        want_step_ :_ag_bu, :A, :B
        want_step_ :_ag_qvi_ONE, :B, :B
        want_step_ :_ag_qvi_TWO, :B, :B
        want_step_ :_ag_bu, :B, :C
      end
    end

    shared_subject :graph_ do

      define_graph_ do |o|
        o.add_state :A, :can_transition_to, :B
        o.add_state :B, :can_transition_to, :C
        o.add_state :C
        o.beginning_state :A
      end
    end

    shared_subject :_imperative_quick_visit_agent do
      define_agent_ do |o|
        o.must_transition_from_to :B, :B
      end
    end

    shared_subject :_quick_visit_agent do
      define_agent_ do |o|
        o.can_transition_from_to :B, :B
      end
    end

    shared_subject :_busy_agent do
      define_agent_ do |o|
        o.must_transition_from_to :A, :B
        o.must_transition_from_to :B, :C
      end
    end
  end
end
# #born: to zoom-in on this aspect of the rearch.
