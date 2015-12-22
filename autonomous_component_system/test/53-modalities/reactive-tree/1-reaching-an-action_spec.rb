require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] modalities - reactive tree - 1. reaching an action" do

    TS_[ self ]
    use :future_expect
    use :modalities_reactive_tree

    it "shoe model loads" do

      Callback_::Name.via_module( shoe_model_ ).as_const.should eql :Shoe
    end

    it "kernel loads" do

      kernel_ or fail
    end

    it "call a strange action" do

      future_expect_only :error, :no_such_action do | ev |

        _s = future_black_and_white ev

        _s.should eql "no such action - 'wazoozle'"
      end

      _x = kernel_.call :wazoozle, & fut_p
      _x.should eql false
    end

    it "call the branch" do

      future_expect :error, :action_name_ends_on_branch_node

      call_ :shoe
      expect_failed_
    end

    it "call the sub-branch under the branch" do

      future_expect :error, :action_name_ends_on_branch_node

      call_ :shoe, :lace
      expect_failed_
    end

    it "call an action under the sub-branch" do

      future_expect_only :info, :expression, :working do | a |
        a.should eql [ "retrieving ** color **" ]
      end

      call_ :shoe, :lace, :get_color
      future_is_now
      @result.should eql "white"
    end
  end
end
