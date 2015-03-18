require_relative '../../../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] VCS adapters - git - models - [THIS]", wip: true do

    extend TS_
    use :expect_event
    use :mock_FS
    use :mock_system

    it "the commit pool builds" do
      repo._commit_pool.should be_respond_to :close_pool
    end

    it "with a repo touch an existant SHA once" do
      @result = repo.SHA_notify _SHA( '234234' )
      expect_next_system_command_emission_
      expect_succeeded
    end

    it "with a repo touch a noent SHA - x" do
      @result = repo.SHA_notify _SHA '456456'
      expect_event_sequence_for_noent_SHA_ '456456'
      expect_result_for_whatever
      expect_no_more_events
    end

    it "touch 2 commits then close the pool, emits only system call events" do
      memoized_manifest  # AWFUL sorry - see last method in this file
    end

    _SUBJ = 'commitpoint manifest'

    it "#{ _SUBJ } can 'commitpoint_count' (2)" do
      memoized_manifest.commitpoint_count.should eql 2
    end

    it "#{ _SUBJ } can 'lookup_commit_with_SHA' (SHA is in manifest)" do
      mani = memoized_manifest
      ci = mani.lookup_commit_with_SHA _SHA '123123'
      ci_ = mani.lookup_commit_with_SHA _SHA '345345'
      ci.SHA.as_symbol.should eql :'123123'
      ci_.SHA.as_symbol.should eql :'345345'
    end

    it "#{ _SUBJ } 'lookup_commit_with_SHA' on outside SHA - X" do
      mani = memoized_manifest
      _sha = _SHA '234234'
      -> do
        mani.lookup_commit_with_SHA _sha
      end.should raise_error ::KeyError, /\Akey not found: -?\d+$/
    end

    it "#{ _SUBJ } can 'lookup_commitpoint_index_of_ci' (chronologiezes)" do
      mani = memoized_manifest
      ci = mani.lookup_commit_with_SHA _SHA '123123'
      ci_ = mani.lookup_commit_with_SHA _SHA '345345'
      idx = mani.lookup_commitpoint_index_of_ci ci
      idx_ = mani.lookup_commitpoint_index_of_ci ci_
      idx.should eql 1
      idx_.should eql 0
      ci.author_datetime.iso8601.should eql "2014-01-05T04:03:24-05:00"
      ci_.author_datetime.iso8601.should eql "2014-01-04T18:33:24-05:00"
    end

    -> do
      p = nil
      q = -> ctx do
        x = ctx.__build_commit_manifest  # meh - yes this is DANGEROUS
        p = -> { x }
        x
      end
      define_method :memoized_manifest do
        p ? p[] : q[ self ]
      end
    end.call

    def __build_commit_manifest
      repo.SHA_notify _SHA '123123'
      @repo.SHA_notify _SHA '345345'
      _x = @repo.close_the_pool
      _x.should eql true
      mani = @repo.sparse_matrix or fail "expected ci manifest"
      expect_next_system_command_emission_
      expect_next_system_command_emission_
      expect_no_more_events
      mani
    end
  end
end
