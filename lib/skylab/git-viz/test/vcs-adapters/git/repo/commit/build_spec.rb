require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git::Repo_

  describe "[gv] VCS adapters git repo commit build" do

    extend TS__ ; use :expect ; use :mock_FS ; use :mock_system

    it "try to build a commit from a noent SHA - x" do
      with_commit_from_SHA '456456'
      expect_event_sequence_and_result_for_noent_SHA '456456'
    end

    def with_commit_from_SHA s
      _sha = _SHA s
      repo ; listener ; _mut = _VCS_const( :Repo_ )::Commit_
      @result = _mut.build_ci @repo, _sha, @listener do |ci|
        ci.set_system_conduit mock_system_conduit
      end ; nil
    end

    it "build a commit object from a typical commit - lookup FD counts" do
      with_commit_from_SHA '123123'
      expect_next_system_command_emission
      expect_no_more_emissions
      counts = @result.lookup_any_filediff_counts_for_normpath(
        "dirzo/everybody in the room is floating" )
      counts.num_insertions.should eql 3
      counts.num_deletions.should eql 2
    end

    def fixtures_module
      my_fixtures_module
    end
  end
end
