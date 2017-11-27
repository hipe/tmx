require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] list - line stream via array" do

    it "loads" do
      _subject_module
    end

    it "when built with array of lines - `gets` - works the same" do  # mirror 2 others

      scn = _subject_module[ [ "one B\n", "two B\n" ] ]

      expect( scn.lineno ).to be_nil

      expect( scn.gets ).to eql "one B\n"

      expect( scn.lineno ).to eql 1

      expect( scn.gets ).to eql "two B\n"

      expect( scn.lineno ).to eql 2

      expect( scn.gets ).to be_nil

      expect( scn.lineno ).to eql 2

      expect( scn.gets ).to be_nil
    end


    it "come in from the end" do

      scn = _subject_module[ %i( A B C D ) ]
      expect( scn.rgets ).to eql :D
      expect( scn.gets ).to eql :A
      expect( scn.rgets ).to eql :C
      expect( scn.gets ).to eql :B
      expect( scn.rgets ).to be_nil
      expect( scn.gets ).to be_nil

    end

    def _subject_module
      Home_::List::LineStream_via_Array
    end
  end
end
