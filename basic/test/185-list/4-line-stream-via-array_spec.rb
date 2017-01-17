require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] list scanner for array" do

    it "loads" do
      subject
    end

    it "when built with array of lines - `gets` - works the same" do  # mirror 2 others

      scn = subject.new [ "one B\n", "two B\n" ]

      scn.lineno.should be_nil

      scn.gets.should eql "one B\n"

      scn.lineno.should eql 1

      scn.gets.should eql "two B\n"

      scn.lineno.should eql 2

      scn.gets.should be_nil

      scn.lineno.should eql 2

      scn.gets.should be_nil
    end


    it "come in from the end" do

      scn = subject.new [ :A, :B, :C, :D ]
      scn.rgets.should eql :D
      scn.gets.should eql :A
      scn.rgets.should eql :C
      scn.gets.should eql :B
      scn.rgets.should be_nil
      scn.gets.should be_nil

    end

    def subject
      Home_::List.line_stream
    end
  end
end
