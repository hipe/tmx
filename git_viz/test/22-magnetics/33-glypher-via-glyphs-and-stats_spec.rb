require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] magnetics - glyphver via [..]" do

    TS_[ self ]
    use :double_decker_memoize

    it "outside range (low end) is nil" do

      expect( _against( -1 ) ).to be_nil
    end

    it "outside range (high end) is nil" do

      expect( _against 122 ).to be_nil
    end

    it "'begin' term is OK" do

      expect( _against 0 ).to eql 0
    end

    it "'end' value is OK" do

      expect( _against 121 ).to eql 2
    end

    it "near cutoff (A.1)" do

      expect( _against 39 ).to eql 0
    end

    it "near cutoff (A.2)" do

      expect( _against 40 ).to eql 1
    end

    it "near cutoff (B.1)" do

      expect( _against 80 ).to eql 1
    end

    it "near cuttoff (B.2)" do

      expect( _against 81 ).to eql 2
    end

    def _against d

      _baked.B_tree.category_for d
    end

    memoize_ :_baked do

      _mapper.bake_for _statistics
    end

    memoize_ :_mapper do

      Home_::Magnetics_::Glypher_via_Glyphs_and_Stats.
        start 'Cr', 'A', 'B', 'C'
    end

    memoize_ :_statistics do

      [0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,
       5,6,6,6,7,8,9,10,13,13,16,23,23,25,30,31,31,34,36,40,42,44,44,45,45,
       51,52,57,59,66,68,78,79,82,121]
    end
  end
end
