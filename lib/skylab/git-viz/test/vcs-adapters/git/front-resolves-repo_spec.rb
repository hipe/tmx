require_relative 'test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git

  describe "[gv] VCS adapters git front resolves repo" do

    extend TS__ ; use :expect ; use :mock_FS

    it "builds" do
      front
    end

    it "pings" do
      front.ping
      expect %i( ping ) do |em|
        em.payload_x.should eql :hello_from_front
      end
      expect_no_more_emissions
    end

    it "just go ahead and TRY to give this low-level nerk a relpath" do
      expect_relative_paths_are_not_honored_here do
        with_procure_from_mock_pathname 'anything'
      end
    end

    def expect_relative_paths_are_not_honored_here &p
      p.should raise_error ::ArgumentError,
        "relative paths are not honored here - anything"
    end

    it "resolve when provide a path that totally doesn't exist - x" do
      with_procure_from_mock_pathname '/totally/doesn-t-exist'
      expect_totally_doesnt_exist
    end

    def expect_totally_doesnt_exist
      expect %i( repo_root_not_found error string ),
        "Didn't find .git in this or any parent directory #{
         }(looked in 3 dirs): /totally/doesn-t-exist"
      expect_failed
    end

    it "give it a FILE in a dir that is a repo - WORKS" do
      with_procure_from_mock_pathname '/derp/berp/core.rb'
      expect_no_more_emissions
      @result.class.should eql Skylab::GitViz::VCS_Adapters_::Git::Repo_  # #todo:during:repo
    end

    def with_procure_from_mock_pathname s
      @result = front.procure_repo_from_pathname mock_pathname s
    end
  end
end
