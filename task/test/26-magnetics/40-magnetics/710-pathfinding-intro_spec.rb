require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - magnetics - pathfinding intro" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics
    use :magnetics_solve_for_X

    context "(context)" do

      it "loads" do
        subject_module_
      end

      it "(builds collection)" do
        o = collection_
        o_ = collection_
        o && o.object_id == o_.object_id or fail
      end

      it "zero hops when target is already a given" do
        target_ :trilean
        given_ :trilean
        expect_stack_
      end

      it "one hop when requisite is given (monadic function)" do
        target_ :trilean
        given_ :channel
        expect_stack_ :Trilean_via_Channel
      end

      it "one hop but requisite not given - error structure" do
        target_ :trilean
        given_
        _stack = expect_failure_structure__
        _stack.fetch(0) == [:channel, :is_startpoint_but_is_not_a_given] || fail
      end

      it "two hops straight yay" do
        target_ :lemmas
        given_ :selection_stack
        expect_stack_(
          :Lemmas_via_Normal_Selection_Stack,
          :Normal_Selection_Stack_via_Selection_Stack,
        )
      end

      it "the first alternation - tiebreak (THIS IS SO COOL)" do

        target_ :message_that_is_single_string

        given_ :channel, :subject_association, :selection_stack

        expect_stack_(
          :Message_That_Is_Single_String_via_First_Line_Map,
          :First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom,
          :Lemmas_via_Normal_Selection_Stack,
          :Normal_Selection_Stack_via_Selection_Stack,
          :Lemmato_Trilean_Idiom_via_Trilean,
          :Trilean_via_Channel,
        )
      end

      dangerous_memoize :collection_ do
        collection_via_path_ fixture_path_ 'magnetics-example-collection-710.list.txt'
      end
    end
  end
end
