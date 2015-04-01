require_relative '../../test-support'

module Skylab::Basic::TestSupport::Tree_TS

  describe "[ba] tree - sessions - merge" do

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
      Subject_[].via :paths, a
    end

    def _go
      @t1.merge_destructively @t2
      NIL_
    end

    define_method :_paths_via_tree, TS_::Paths_via_tree.to_proc

  end
end
