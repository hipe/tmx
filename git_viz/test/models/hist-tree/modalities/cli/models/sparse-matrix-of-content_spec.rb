require_relative '../../../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - hist-tree - CLI - models - sparse matrix of content" do

    extend TS_
    use :VCS_adapters_git_support_bundle_support

    it "loads" do
      _subject
    end

    it "sparse row, each cel knows if it is first, and its amount classification" do

      bundle_against_ '/m04/repo'

      _table = _subject.new_via_bundle_and_repository @bundle, @repository

      _table.rows.length.should eql 3

      row = _table.rows.fetch 0

      a = row.to_a

      a.length.should eql 5

      a[ 0 ].should be_nil

      mfc = a.fetch 1
      mfc.is_first.should eql true
      mfc.change_count.should eql 1

      mfc = a.fetch 2
      mfc.is_first.should eql false
      mfc.change_count.should eql 2

      a[ 3 ].should be_nil

      mfc = a.fetch 4
      mfc.is_first.should eql false
      mfc.change_count.should eql 2

    end

    def _subject
      Home_::Models_::Hist_Tree::Modalities::CLI::Models_::Sparse_Matrix_of_Content
    end

    def manifest_path_for_mock_FS
      at_ :STORY_04_PATHS_
    end

    def manifest_path_for_mock_system
      at_ :STORY_04_COMMANDS_
    end
  end
end
