require_relative '../../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - merged tree via trees - sub-magnetics" do

    TS_[ self ]
    use :tree

    it "loads" do

      _subject
    end

    it "merge two ints" do

      expect( _subject.merge_atomic( 1, 2 ) ).to eql 3
    end

    it "merge to floats" do

      expect( _subject.merge_atomic( 1.2, 3.4 ) ).to eql 4.6
    end

    it "merging an int and a float upgrades" do

      expect( _subject.merge_atomic( 1, 2.0 ) ).to eql 3.0
    end

    it "merging a float and an int same" do

      expect( _subject.merge_atomic( 2.0, 1 ) ).to eql 3.0
    end

    it "int vs. nil - int wins" do

      expect( _subject.merge_atomic( nil, 1 ) ).to eql 1
    end

    it "int vs. strange object" do

      _rx = /'list' doesn't `merge_atomic`/
      begin
        _subject.merge_atomic [], 1
      rescue Home_::ArgumentError => e
      end
      expect( e.message ).to match _rx
    end

    it "bool and int - no" do

      _rx = /won't merge an int into a bo/
      begin
        _subject.merge_atomic true, 1
      rescue Home_::ArgumentError => e
      end
      expect( e.message ).to match _rx
    end

    it "merge two arrays - wat" do

      _x = _subject.merge_one_dimensional ['a','b'], ['c','d']
      expect( _x ).to eql %w| a b c d |
    end

    def _subject
      subject_module_::Magnetics::MergedTree_via_Trees
    end
  end
end
