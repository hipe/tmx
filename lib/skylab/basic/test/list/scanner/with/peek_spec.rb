require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Scanner::With::Peek

  ::Skylab::Basic::TestSupport::List::Scanner::With[ self ]

  include CONSTANTS

  Basic = ::Skylab::Basic

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Basic::List::Scanner::With::Peek" do
    context "list scanner with peek" do
      Sandbox_1 = Sandboxer.spawn
      it "like this" do
        Sandbox_1.with self
        module Sandbox_1
          scn = Basic::List::Scanner[ %i( a b ) ]
          Basic::List::Scanner::With[ scn, :peek ]
          scn.gets.should eql( :a )
          scn.peek.should eql( :b )
          scn.gets.should eql( :b )
          scn.peek.should eql( nil )
        end
      end
    end
  end
end
