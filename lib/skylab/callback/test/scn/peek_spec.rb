require_relative 'test-support'

module Skylab::Callback::TestSupport::Scn

  describe "[cb] scn peek" do
    context "hack a minimal scanner to also respond to a `peek` method" do
      Sandbox_1 = Sandboxer.spawn
      it "like this" do
        Sandbox_1.with self
        module Sandbox_1
          _scn = Basic_::List.line_stream %i( a b )
          scn = Callback_::Scn.peek.gets_under _scn
          scn.gets.should eql( :a )
          scn.peek.should eql( :b )
          scn.gets.should eql( :b )
          scn.peek.should eql( nil )
        end
      end
    end
  end
end
