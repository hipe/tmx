require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] list - line stream via array" do

    it "loads" do
      _subject_module
    end

    it "when built with array of lines - `gets` - works the same" do  # mirror 2 others

      scn = _subject_module[ [ "one B\n", "two B\n" ] ]

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

      scn = _subject_module[ %i( A B C D ) ]
      scn.rgets.should eql :D
      scn.gets.should eql :A
      scn.rgets.should eql :C
      scn.gets.should eql :B
      scn.rgets.should be_nil
      scn.gets.should be_nil

    end

    def _subject_module
      Home_::List::LineStream_via_Array
    end
  end
end
