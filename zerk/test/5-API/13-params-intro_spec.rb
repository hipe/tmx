require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - params intro", wip:true do  # used to test r.t

    TS_[ self ]
    # use :future_expect
    # use :modalities_reactive_tree

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

      self._BREAKUP

      future_expect :error, :action_name_ends_on_branch_node

      call_root_ACS :shoe
      expect_failed_
    end

    it "call the sub-branch under the branch" do

      self._BREAKUP

      future_expect :error, :action_name_ends_on_branch_node

      call_root_ACS :shoe, :lace
      expect_failed_
    end

    it "call an action under the sub-branch" do

      future_expect_only :info, :expression, :working do | a |
        a.should eql [ "retrieving ** color **" ]
      end

      call_root_ACS :shoe, :lace, :get_color
      future_is_now
      @result.should eql "white"
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_21_Another_Shoe ]
    end
  end
end
