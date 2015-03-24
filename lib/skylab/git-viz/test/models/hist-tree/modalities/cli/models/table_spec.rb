require_relative '../../../../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] VCS adapters - git - models - hist-tree - CLI - models - table :[#026]" do

    extend TS_

    it "outside range (low end) is nil" do

      _against( -1 ).should be_nil
    end

    it "outside range (high end) is nil" do

      _against( 122 ).should be_nil
    end

    it "'begin' term is OK" do

      _against( 0 ).should eql 0
    end

    it "'end' value is OK" do

      _against( 121 ).should eql 2
    end

    it "near cutoff (A.1)" do

      _against( 39 ).should eql 0
    end

    it "near cutoff (A.2)" do

      _against( 40 ).should eql 1
    end

    it "near cutoff (B.1)" do

      _against( 80 ).should eql 1
    end

    it "near cuttoff (B.2)" do

      _against( 81 ).should eql 2
    end

    def _against d

      _mapper.B_tree.category_for d
    end

    memoize :_mapper do

      GitViz_::Models_::Hist_Tree::Modalities::CLI::Models_::Table::
        Build_glyph_mapper___.new(
          _statistics, 'Cr', 'A', 'B', 'C' ).execute
    end

    memoize :_statistics do

      [0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,
       5,6,6,6,7,8,9,10,13,13,16,23,23,25,30,31,31,34,36,40,42,44,44,45,45,
       51,52,57,59,66,68,78,79,82,121]
    end
  end
end
