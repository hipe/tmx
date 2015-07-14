require_relative '../../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - bundle" do

    extend TS_
    use :VCS_adapters_git_support_bundle_support

    it "noent - soft error" do

      bundle_against_ '/m03/repo/xx/not-there'
      expect_failed_by :start_directory_does_not_exist
    end

    it "file - soft error" do

      bundle_against_ "/m03/repo/dirzo/it's just/funky like that"
      expect_failed_by :wrong_ftype
    end

    it "dir that is not tracked - soft error" do

      bundle_against_ "/m03/repo/these-dirs/not-tracked"
      expect_failed_by :directory_is_not_tracked
    end

    it "boogie boogie boogie boogie boogie" do

      bundle_against_ "/m03/repo/dirzo"

      bnch = @bundle
      bnch.should be_respond_to :ci_box
      bnch.trails.length.should eql 3
      @trail = bnch.trails.fetch 0
      __expect_trail
    end

    def __expect_trail

      trl = @trail
      a = trl.filechanges
      a.length.should eql 2

      bfc = a.fetch 0

      bfc.SHA.string.should eql 'fafa002000000000000000000000000000000000'
      bfc.fc.insertion_count.should eql 3
      bfc.fc.deletion_count.should be_zero

      bfc = a.fetch 1
      bfc.SHA.string.should eql 'fafa003000000000000000000000000000000000'
      bfc.fc.insertion_count.should eql 3
      bfc.fc.deletion_count.should eql 2

    end

    def manifest_path_for_mock_FS
      at_ :STORY_03_PATHS_
    end

    def manifest_path_for_mock_system
      at_ :STORY_03_COMMANDS_
    end
  end
end
