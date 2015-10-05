require_relative 'test-support'

module Skylab::Callback::TestSupport::Scn

  describe "[ca] Scn__::Peek__" do

    it "like this" do
      _scn = Basic_::List.line_stream %i( a b )
      scn = Home_::Scn.peek.gets_under _scn
      scn.gets.should eql :a
      scn.peek.should eql :b
      scn.gets.should eql :b
      scn.peek.should eql nil
    end
  end
end
