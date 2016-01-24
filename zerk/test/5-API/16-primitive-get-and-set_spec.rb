require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - depth and params integration", wip: true do  # used to test r.t

    TS_[ self ]
    use :memoizer_methods
    # use :future_expect
    # use :modalities_reactive_tree

    context "several component association with proc-like models.." do

      it "one with no assoc-operations is not exposed to the UI" do

        _init_fresh_setup

        @_shoe._did_run_.should be_nil

        future_expect_only :error, :no_such_action

        call_root_ACS :ugg, :looks_like_proc_but_no_operations

        @_shoe._did_run_.should eql true

        @result.should eql false
      end

      it "omg the hypothetic `get` would work" do

        _init_fresh_setup

        call_root_ACS :ugg, :shoestring_length, :abrufen

        @result.should eql :_was_not_known_

        @_shoe.instance_variable_set :@shoestring_length, :zizzy

        call_root_ACS :ugg, :shoestring_length, :abrufen

        @result.should eql [ :_was_known_huddaugh_, :zizzy ]
      end

      it "and check out this `set` that takes an invalid" do

        _init_fresh_setup

        future_expect_only :error, :expression, :nope do | s_a |
          [ "doesn't look like integer: \"98 degrees\"" ]
        end

        @_shoe._recv_etc( & fut_p )

        call_root_ACS :ugg, :shoestring_length, :stellen, :length, '98 degrees'

        @result.should eql false
      end

      it "and yes, yay, take valid" do

        _init_fresh_setup

        call_root_ACS :ugg, :shoestring_length, :stellen, :length, '98'

        @_shoe.instance_variable_get( :@shoestring_length ).should eql 98

        @result.should eql :_you_did_it_
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_22_Uggs ]
    end
  end
end
