require_relative '../../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  describe "[gv] VCS adapters - git - models - bundle" do

    extend TS_
    use :repository_support


    it "noent - soft error" do

      _against '/m03/repo/xx/not-there'
      expect_failed_by :errno_enoent
    end

    it "file - soft error" do

      _against "/m03/repo/dirzo/it's just/funky like that"
      expect_failed_by :wrong_ftype
    end

    it "dir that is not tracked - soft error" do

      _against "/m03/repo/these-dirs/not-tracked"
      expect_failed_by :directory_is_not_tracked
    end

    it "boogie boogie boogie boogie boogie" do

      _against "/m03/repo/dirzo"

      bnch = @bunch
      bnch.should be_respond_to :ci_box
      bnch.trails.length.should eql 3
      @trail = bnch.trails.fetch 0
      __expect_trail
    end

    def __expect_trail

      trl = @trail
      trl.length.should eql 1  # currently there is no trail that is not 1 in length :(

      bfc = trl.fetch 0

      bfc.SHA.string.should eql 'fafa030300000000000000000000000000000000'
      bfc.fc.insertion_count.should eql 3
      bfc.fc.deletion_count.should eql 2

      # we used to check `commitpoint_index`, we do no longer

    end

    def _against abs

      init_respository_via_pathname_ mock_pathname abs

      x = subject_VCS::Models_::Bundle.build_via_path_and_repo(

        @repository.relative_path_of_interest,
        @repository,
        & handle_event_selectively )

      if x
        @bunch = x
      else
        @result = x
      end

      NIL_
    end

    def manifest_path_for_mock_FS
      STORY_03_PATHS_
    end

    def manifest_path_for_mock_system
      STORY_03_COMMANDS_
    end
  end
end
