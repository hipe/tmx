require_relative '../../test-support'

module Skylab::Basic::TestSupport::Tree_TS

  describe "[ba] tree - sessions - merge - actors" do

    it "loads" do

      _subject
    end

    it "merge two ints" do

      _subject.merge_atomic( 1, 2 ).should eql 3
    end

    it "merge to floats" do

      _subject.merge_atomic( 1.2, 3.4 ).should eql 4.6
    end

    it "merging an int and a float upgrades" do

      _subject.merge_atomic( 1, 2.0 ).should eql 3.0
    end

    it "merging a float and an int same" do

      _subject.merge_atomic( 2.0, 1 ).should eql 3.0
    end

    it "int vs. nil - int wins" do

      _subject.merge_atomic( nil, 1 ).should eql 1
    end

    it "int vs. strange object" do

      _rx = /'list' doesn't `merge_atomic`/
      begin
        _subject.merge_atomic [], 1
      rescue ::ArgumentError => e
      end
      e.message.should match _rx
    end

    it "bool and int - no" do

      _rx = /won't merge an int into a bo/
      begin
        _subject.merge_atomic true, 1
      rescue ::ArgumentError => e
      end
      e.message.should match _rx
    end

    it "merge two arrays - wat" do

      _x = _subject.merge_one_dimensional ['a','b'], ['c','d']
      _x.should eql %w| a b c d |
    end

    def _subject
      Subject_[]::Sessions_::Merge
    end
  end
end
