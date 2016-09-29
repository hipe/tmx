require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] scn - peek" do

    it "like this" do

      _scn = Home_.lib_.basic::List.line_stream %i( a b )
      scn = Home_::Scn.peek.gets_under _scn
      scn.gets.should eql :a
      scn.peek.should eql :b
      scn.gets.should eql :b
      scn.peek.should eql nil
    end
  end
end
