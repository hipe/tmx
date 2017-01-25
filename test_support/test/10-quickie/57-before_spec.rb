require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - before" do

    TS_[ self ]
    use :memoizer_methods
    use :quickie

    context "before all (NOTE this is simplified from what rspec offers..)" do

      # [#009.E] (not shown in tests) the quickie before(:all) is
      # dumbed down from rspec in at least two ways:
      #
      #   1) it is not executed in a test context but in the defined
      #      context. this is to prevent you from making mistakes:
      #      the context instance of whatever test happens to run first
      #      should not be accessible to a block whose side-effects
      #      could affect all tests in its scope
      #
      #   2) we don't want to bother with supporting nested before(:all)
      #      blocks. it's annoying to implement and can create confusing
      #      tests. rather, we bork. implement such things with plain old
      #      programming.

      # -

      shared_subject :_state do
        _same_tests :all
      end

      it "ran the `before :all` only once" do
        _count == 1 || fail
      end
    end

    context "before each" do

      shared_subject :_state do
        _same_tests :each
      end

      it "ran the `before :all` twice" do
        _count == 2 || fail
      end
    end

    # ==

    def _same_tests each_or_all

      count = 0
      ran_these = []
      given_this_context_ do

        before each_or_all do
          count += 1
        end

        it "eg1" do
          ran_these.push :eg_1_ran
        end

        it "eg2" do
          ran_these.push :eg_2_ran
        end
      end

      _client = run_the_context_
      _client._stats_FOR_TEST_.example_count == 2 || fail

      ran_these == [ :eg_1_ran, :eg_2_ran ] || fail

      [ count ]
    end

    def _count
      _state.fetch 0
    end

    # ==

    # ==
  end
end
# #born years later
