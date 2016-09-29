require_relative '../../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - sessions - merge" do

    TS_[ self ]
    use :tree

    it "merge monadic trees - different" do

      @t1 = _tree_via_paths %w| sky |
      @t2 = _tree_via_paths %w| lab |
      _go
      _paths_via_tree( @t1 ).should eql( %w| sky lab | )
    end

    it "merge monadic trees - same" do

      @t1 = _tree_via_paths %w| sky |
      @t2 = _tree_via_paths %w| sky |
      _go
      _paths_via_tree( @t1 ).should eql( %w| sky | )
    end

    it "merge 2-deep stem-trees, totally different" do

      @t1 = _tree_via_paths %w| sky/lab |
      @t2 = _tree_via_paths %w| bot/noise |
      _go
      _paths_via_tree( @t1 ).should eql( %w| sky/ sky/lab bot/ bot/noise | )
    end

    it "merge where lvl 1 is same, lvl2 is different" do

      @t1 = _tree_via_paths %w| sky/hl |
      @t2 = _tree_via_paths %w| sky/face |
      _go
      _paths_via_tree( @t1 ).should eql( %w| sky/ sky/hl sky/face | )
    end

    def _tree_via_paths a
      subject_module_.via :paths, a
    end

    def _go
      @t1.merge_destructively @t2
      NIL_
    end

    def _paths_via_tree tree
      tree.to_stream_of( :paths ).to_a
    end
  end
end
