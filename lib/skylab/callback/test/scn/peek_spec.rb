require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Scanner::With::Peek

  ::Skylab::Basic::TestSupport::List::Scanner::With[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Basic_ = Basic_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[ba] List::Scanner::With::Peek" do
    context "list scanner with peek" do
      Sandbox_1 = Sandboxer.spawn
      it "like this" do
        Sandbox_1.with self
        module Sandbox_1
          scn = Basic_::List::Scanner[ %i( a b ) ]
          Basic_::List::Scanner::With[ scn, :peek ]
          scn.gets.should eql( :a )
          scn.peek.should eql( :b )
          scn.gets.should eql( :b )
          scn.peek.should eql( nil )
        end
      end
    end
  end
end
