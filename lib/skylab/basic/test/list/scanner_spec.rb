require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Scanner

  ::Skylab::Basic::TestSupport::List[ self ]

  include CONSTANTS

  Basic = ::Skylab::Basic

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Basic::List::Scanner" do
    context "basic list scanner" do
      Sandbox_1 = Sandboxer.spawn
      it "aggregates other scanners, makes them behave as one sequence of scanners" do
        Sandbox_1.with self
        module Sandbox_1
          scn = Basic::List::Scanner::Aggregate[
              Basic::List::Scanner[ [ :a, :b ] ],
              Basic::List::Scanner[ [ ] ],
              Basic::List::Scanner[ [ :c ] ] ]
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
