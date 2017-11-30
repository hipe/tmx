require_relative '../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - commit" do

    TS_[ self ]
    use :VCS_adapters_git_commits

    it "try to build a commit from a noent commit - there is a custom error event" do

      __using_story_02

      _against_string 'no-such-commit'

      want_event_sequence_for_noent_SHA_ 'no-such-commit'
      expect( @ci ).to eql false
      want_no_more_events
    end

    it "build a commit object from a typical commit - lookup FC counts" do

      __using_story_03

      _against_string 'fafa003'

      want_next_system_command_emission_
      want_no_more_events

      fc = @ci.fetch_filechange_via_end_path(
        "dirzo/everybody in the room is floating" )

      expect( fc.insertion_count ).to eql 3
      expect( fc.deletion_count ).to eql 2
    end

    def _against_string s

      _repo = front_.new_repository_via(
        @path,
        stubbed_system_conduit,
        stubbed_filesystem,
      )

      @ci = _repo.fetch_commit_via_identifier s

      NIL_
    end

    def manifest_path_for_stubbed_FS
      @stubbed_FS
    end

    def manifest_path_for_stubbed_system
      @mock_SYS
    end

    def __using_story_02

      @stubbed_FS = at_ :STORY_02_PATHS_
      @mock_SYS = at_ :STORY_02_COMMANDS_
      @path = '/m02/repo'
    end

    def __using_story_03

      @stubbed_FS = at_ :STORY_03_PATHS_
      @mock_SYS = at_ :STORY_03_COMMANDS_
      @path = '/m03/repo'
    end
  end
end
