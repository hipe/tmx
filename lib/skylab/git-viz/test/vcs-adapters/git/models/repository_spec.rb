require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  describe "[gv] VCS adapters - git - models - repository" do

    extend TS_
    use :repository_support

    it "builds" do
      front_
    end

    it "pings" do
      x = front_.ping
      expect_OK_event :ping, "hello from front."
      x.should eql :hello_from_front
      expect_no_more_events
    end

    it "just go ahead and TRY to give this low-level nerk a relpath" do
      __expect_relative_paths_are_not_honored_here do
        init_respository_via_pathname_ 'anything'
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
      init_respository_via_pathname_ '/totally/doesn-t-exist'
      __expect_totally_doesnt_exist
    end

    def __expect_totally_doesnt_exist

      expect_not_OK_event :repo_root_not_found do | ev |

        ev.filename.should eql '.git'
        ev.num_times_looked.should eql 3
        ev.path.should eql "/totally/doesn-t-exist"
      end

      expect_failed
    end

    it "give it a FILE in a dir that is a repo - WORKS" do

      init_respository_via_pathname_ '/m02/repo/core.py'
      expect_no_more_events
      @repository.should be_respond_to :fetch_commit_via_identifier
    end

    def manifest_path_for_mock_FS
      STORY_02_PATHS_
    end

    def mock_system_conduit
      :_none_used_here_
    end
  end
end
