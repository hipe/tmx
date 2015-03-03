require_relative 'test-support'

module Skylab::SubTree::TestSupport::Tree

  if false  # #todo:next-commit
  describe "[st] tree merge" do

    def tree_from_paths a
      Subject_[].from :paths, a
    end

    it "merge monadic trees - different" do
      t1 = tree_from_paths %w| sky |
      t2 = tree_from_paths %w| lab |
      t1.destructive_merge t2
      t1.to_paths.should eql( %w| sky lab | )
    end

    it "merge monadic trees - same" do
      t1 = tree_from_paths %w| sky |
      t2 = tree_from_paths %w| sky |
      t1.destructive_merge t2
      t1.to_paths.should eql( %w| sky | )
    end

    it "merge 2-deep stem-trees, totally different" do
      t1 = tree_from_paths %w| sky/lab |
      t2 = tree_from_paths %w| bot/noise |
      t1.destructive_merge t2
      t1.to_paths.should eql( %w| sky/ sky/lab bot/ bot/noise | )
    end

    it "merge where lvl 1 is same, lvl2 is different" do
      t1 = tree_from_paths %w| sky/hl |
      t2 = tree_from_paths %w| sky/face |
      t1.destructive_merge t2
      t1.to_paths.should eql( %w| sky/ sky/hl sky/face | )
    end
  end
  end
end
