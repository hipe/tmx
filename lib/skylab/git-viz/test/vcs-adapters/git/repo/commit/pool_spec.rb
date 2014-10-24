require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git::Repo

  describe "[gv] VCS adapters git repo commit pool" do

    extend TS__ ; use :expect ; use :mock_FS ; use :mock_system

    it "the commit pool builds" do
      repo.send :commit_pool
    end

    it "with a repo touch an existant SHA once" do
      _sha = _SHA '234234'
      @result = repo.SHA_notify _sha
      expect_next_system_command_emission
      @result.should eql true
    end

    it "with a repo touch a noent SHA - x" do
      repo ; _sha = _SHA '456456'
      @result = @repo.SHA_notify _sha
      expect_event_sequence_and_result_for_noent_SHA '456456'
    end

    it "touch 2 commits then close the pool, emits only system call events" do
      mani
    end

    _SUBJ = 'commitpoint manifest'

    it "#{ _SUBJ } can 'commitpoint_count' (2)" do
      mani.commitpoint_count.should eql 2
    end

    it "#{ _SUBJ } can 'lookup_commit_with_SHA' (SHA is in manifest)" do
      ci = mani.lookup_commit_with_SHA _SHA '123123'
      ci_ = mani.lookup_commit_with_SHA _SHA '345345'
      ci.SHA.as_symbol.should eql :'123123'
      ci_.SHA.as_symbol.should eql :'345345'
    end

    it "#{ _SUBJ } 'lookup_commit_with_SHA' on outside SHA - X" do
      mani ; _sha = _SHA '234234'
      -> do
        @mani.lookup_commit_with_SHA _sha
      end.should raise_error ::KeyError, /\Akey not found: -?\d+$/
    end

    it "#{ _SUBJ } can 'lookup_commitpoint_index_of_ci' (chronologiezes)" do
      ci = mani.lookup_commit_with_SHA _SHA '123123'
      ci_ = @mani.lookup_commit_with_SHA _SHA '345345'
      idx = @mani.lookup_commitpoint_index_of_ci ci
      idx_ = @mani.lookup_commitpoint_index_of_ci ci_
      idx.should eql 1
      idx_.should eql 0
      ci.author_datetime.iso8601.should eql "2014-01-05T04:03:24-05:00"
      ci_.author_datetime.iso8601.should eql "2014-01-04T18:33:24-05:00"
    end

    -> do
      meh_p = -> ctx do
        r = ctx.build_commit_manifest ; meh_p = -> _ { r } ; r
      end
      define_method :mani do
        @mani ||= meh_p[ self ]
      end
    end.call

    def build_commit_manifest
      repo
      @repo.SHA_notify _SHA '123123'
      @repo.SHA_notify _SHA '345345'
      r = @repo.close_the_pool
      r.should eql true
      mani = @repo.sparse_matrix or fail "expected ci manifest"
      expect_next_system_command_emission
      expect_next_system_command_emission
      expect_no_more_emissions
      mani
    end

    def fixtures_module
      my_fixtures_module
    end
  end
end
