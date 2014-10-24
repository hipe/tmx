require_relative 'test-support'

module Skylab::Callback::TestSupport::Scn

  describe "[hl] scn (lib)" do

    context "basic list scanner aggregate" do
      Sandbox_2 = Sandboxer.spawn
      it "aggregates other scanners, makes them behave as one sequence of scanners" do
        Sandbox_2.with self
        module Sandbox_2
          scn = Callback_::Scn.aggregate(
            Basic_::List.line_scanner( [ :a, :b ] ),
            Basic_::List.line_scanner( [] ),
            Basic_::List.line_scanner( [ :c ] ) )
          scn.count.should eql( 0 )
          scn.gets.should eql( :a )
          scn.count.should eql( 1 )
          scn.gets.should eql( :b )
          scn.count.should eql( 2 )
          scn.gets.should eql( :c )
          scn.count.should eql( 3 )
          scn.gets.should eql( nil )
          scn.count.should eql( 3 )
        end
      end
    end
  end
end
