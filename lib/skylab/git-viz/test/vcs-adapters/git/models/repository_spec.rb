require_relative 'test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  describe "[gv] VCS adapters - git - front resolves repo" do

    extend TS_
    use :expect_event
    use :mock_FS

    it "builds" do
      front
    end

    it "pings" do
      x = front.ping
      expect_OK_event :ping, "hello from front."
      x.should eql :hello_from_front
      expect_no_more_events
    end

    it "just go ahead and TRY to give this low-level nerk a relpath" do
      __expect_relative_paths_are_not_honored_here do
        _with_procure_from_mock_pathname 'anything'
      end
    end

    def __expect_relative_paths_are_not_honored_here &p
      p.should raise_error ::ArgumentError,
        "relative paths are not honored here - anything"
    end

    it "resolve when provide a path that totally doesn't exist - x" do
      _with_procure_from_mock_pathname '/totally/doesn-t-exist'
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
      _with_procure_from_mock_pathname '/derp/berp/core.rb'
      expect_no_more_events
      @result.should be_respond_to :lookup_commit_with_SHA
    end

    def _with_procure_from_mock_pathname s
      @result = front.procure_repo_from_pathname mock_pathname s
    end
  end
end
