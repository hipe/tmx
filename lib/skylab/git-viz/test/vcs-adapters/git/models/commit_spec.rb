require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  describe "[gv] VCS adapters - git - models - commit" do

    extend TS_
    use :expect_event
    use :mock_FS
    use :mock_system
    use :commit_support

    it "try to build a commit from a noent commit - there is a custom error event" do

      __using_story_02

      _against_string 'no-such-commit'

      expect_event_sequence_for_noent_SHA_ 'no-such-commit'
      @ci.should eql false
      expect_no_more_events
    end

    it "build a commit object from a typical commit - lookup FC counts" do

      __using_story_03

      debug!

      _against_string 'fafa003'

      expect_next_system_command_emission_
      expect_no_more_events

      fc = @ci.fetch_filechange_via_end_path(
        "dirzo/everybody in the room is floating" )

      fc.insertion_count.should eql 3
      fc.deletion_count.should eql 2
    end

    def _against_string s

      _repo = front_.new_repository_via_pathname mock_pathname @path

      @ci = _repo.fetch_commit_via_identifier s

      NIL_
    end

    def manifest_path_for_mock_FS
      @mock_FS
    end

    def manifest_path_for_mock_system
      @mock_SYS
    end

    def __using_story_02

      @mock_FS = STORY_02_PATHS_
      @mock_SYS = STORY_02_COMMANDS_
      @path = '/m02/repo'
    end

    def __using_story_03

      @mock_FS = STORY_03_PATHS_
      @mock_SYS = STORY_03_COMMANDS_
      @path = '/m03/repo'
    end
  end
end