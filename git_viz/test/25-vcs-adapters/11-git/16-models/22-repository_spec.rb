require_relative '../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - repository" do

    TS_[ self ]
    use :VCS_adapters_git_repository

    it "builds" do
      front_
    end

    it "pings" do

      x = front_.ping

      expect_neutral_event :ping, "hello from front."

      x.should eql :hello_from_front

      expect_no_more_events
    end

    it "just go ahead and TRY to give this low-level nerk a relpath" do

      __expect_relative_paths_are_not_honored_here do

        init_respository_via_path_ 'anything'
      end
    end

    def __expect_relative_paths_are_not_honored_here
      begin
        yield
      rescue ::ArgumentError => e
      end
      e.message.should eql "relative paths are not honored here - anything"
    end

    it "resolve when provide a path that totally doesn't exist - x" do

      init_respository_via_path_ '/totally/doesn-t-exist'

      _ev = start_directory_noent_

      __expect_totally_doesnt_exist _ev
    end

    def __expect_totally_doesnt_exist ev

      ev.exception or fail
      ev.prop or fail
      ev.start_path.should eql '/totally/doesn-t-exist'
    end

    it "give it a FILE in a dir that is a repo - WORKS" do

      init_respository_via_path_ '/m02/repo/core.py'

      expect_no_more_events

      @repository.should be_respond_to :fetch_commit_via_identifier
    end

    def manifest_path_for_stubbed_FS
      at_ :STORY_02_PATHS_
    end

    undef_method :stubbed_system_conduit

    def stubbed_system_conduit
      :_none_used_here_
    end
  end
end
