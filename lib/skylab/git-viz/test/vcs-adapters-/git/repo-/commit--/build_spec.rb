require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git::Repo_

  describe "[gv] VCS adapters git repo commit build" do

    extend TS__ ; use :expect ; use :mock_FS ; use :mock_system

    it "try to build a commit from a noent SHA - x" do
      with_commit_from_SHA '456456'
      expect_result_for_noent_SHA
    end

    def with_commit_from_SHA s
      _VCS_adapter_module::Front.class  # this must be loaded first always (a.l)
      _sha = _SHA s
      repo ; listener ; _mut = _VCS_adapter_module::Repo_::Commit_
      @result = _mut.build_ci @repo, _sha, @listener do |sa|
        sa.set_system_conduit mock_system_conduit
      end ; nil
    end

    def expect_result_for_noent_SHA
      expect_next_system_command_event
      expect %i( unexpected_stderr line ), "fatal: bad revision '456456'"
      expect %i( unexpected exitstatus ) do |em|
        em.payload_x.should eql 128
      end
      expect_no_more_emissions
      @result.should eql false
    end

    it "build a commit object from a typical commit - lookup FD counts" do
      with_commit_from_SHA '123123'
      expect_next_system_command_event
      expect_no_more_emissions
      counts = @result.lookup_filediff_counts_for_normpath(
        "dirzo/everybody in the room is floating" )
      counts.num_insertions.should eql 3
      counts.num_deletions.should eql 2
    end

    def expect_next_system_command_event
      expect %i( next_system command )
    end

    def fixtures_module
      my_fixtures_module
    end
  end
end
