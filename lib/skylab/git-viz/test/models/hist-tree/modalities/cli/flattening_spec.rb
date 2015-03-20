require_relative '../../../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] VCS adapters - git - models - hist-tree - CLI - flattening" do

    extend TS_

    require Top_TS_::VCS_Adapters::Git.dir_pathname.join( 'test-support' ).to_path

    _o = Top_TS_::VCS_Adapters::Git
    _o::Bundle_Support[ self ]

    it "loads" do
      _subject
    end

    it "sparse row, each cel knows if it is first, and its amount classification" do

      bundle_against_ '/m04/repo'

      _table = _subject.new_via_bundle_and_repository @bundle, @repository

      _table.rows.length.should eql 3

      row = _table.rows.fetch 0

      row.length.should eql 5

      row[ 0 ].should be_nil

      row[ 1 ].is_first.should eql true
      row[ 1 ].amount_classification.should be_zero

      row[ 2 ].is_first.should eql false
      row[ 2 ].amount_classification.should eql 1

      row[ 3 ].should be_nil

      row[ 4 ].is_first.should eql false
      row[ 4 ].amount_classification.should eql 1

    end

    def _subject
      GitViz_::Models_::Hist_Tree::Modalities::CLI::Models_::Table
    end

    def manifest_path_for_mock_FS
      GIT_STORY_04_PATHS_
    end

    def manifest_path_for_mock_system
      GIT_STORY_04_COMMANDS_
    end
  end
end
