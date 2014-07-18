require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Scanner

  ::Skylab::Basic::TestSupport::List[ self ]

  include CONSTANTS

  Basic = ::Skylab::Basic

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "[ba] List::Scanner" do
    context "basic list scanner" do
      Sandbox_1 = Sandboxer.spawn
      it "like this" do
        Sandbox_1.with self
        module Sandbox_1
          a = %i( only_one )
          scn = Basic::List::Scanner.new do a.shift end
          scn.gets.should eql( :only_one )
          scn.gets.should eql( nil )
        end
      end
    end
    context "basic list scanner aggregate" do
      Sandbox_2 = Sandboxer.spawn
      it "aggregates other scanners, makes them behave as one sequence of scanners" do
        Sandbox_2.with self
        module Sandbox_2
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
