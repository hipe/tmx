require_relative 'test-support'

module Skylab::SubTree::TestSupport::Tree

  describe "[st] tree mege fun" do

    it "loads" do
      fun
    end

    def fun
      Subject_[]::Merge_::FUN
    end

    it "merge two ints" do
      fun.merge_atomic[ 1, 2 ].should eql( 3 )
    end

    it "merge to floats" do
      fun.merge_atomic[ 1.2, 3.4 ].should eql( 4.6 )
    end

    it "merging an int and a float upgrades" do
      r = fun.merge_atomic[ 1, 2.0 ]
      r.should be_kind_of( ::Float )
      r.should eql( 3.0 )
    end

    it "merging a float and an int same" do
      r = fun.merge_atomic[ 2.0, 1 ]
      r.should be_kind_of( ::Float )
      r.should eql( 3.0 )
    end

    it "int vs. nil - int wins" do
      fun.merge_atomic[ nil, 1 ].should eql( 1 )
    end

    it "int vs. strange object" do
      -> do
        fun.merge_atomic[ [], 1 ]
      end.should raise_error( ::RuntimeError, /'list' doesn't `merge_atomic`/ )
    end

    it "bool and int - no" do
      -> do
        fun.merge_atomic[ true, 1 ]
      end.should raise_error( ::RuntimeError, /won't merge an int into a bo/ )
    end

    it "merge two arrays - wat" do
      x = fun.merge_one_dimensional[ ['a','b'], ['c','d'] ]
      x.should eql( %w| a b c d | )
    end
  end
end
