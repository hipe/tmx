require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Scanner::For

  describe "[ba] list scanner for array" do

    it "when built with array of lines - `gets` - works the same" do  # mirror 2 others
      scn = Basic::List::Scanner::For::Array.new [ "one B\n", "two B\n" ]
      scn.line_number.should be_nil
      scn.gets.should eql "one B\n"
      scn.line_number.should eql 1
      scn.gets.should eql "two B\n"
      scn.line_number.should eql 2
      scn.gets.should be_nil
      scn.line_number.should eql 2
      scn.gets.should be_nil
    end
  end
end
