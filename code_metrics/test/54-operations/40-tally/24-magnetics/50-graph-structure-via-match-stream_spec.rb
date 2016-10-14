require_relative '../../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] tally - magnetics - graph structure" do

    TS_[ self ]
    use :memoizer_methods
    use :operations_tally_magnetics

    it "builds" do
      _state
    end

    it "includes the feature with no match" do

      s = 'THING_THREE'
      _found = _state.features.detect do | o |
        s == o.surface_string
      end
      _found or fail
    end

    it "the features occur in argument order" do

      _ = _state.features
      _had = _.map( & :surface_string )
      _had.should eql %w( THING_TWO THING_ONE THING_THREE )
    end

    it "bucket tree - all the paths are there" do

      _act = _state.bucket_tree.to_stream_of( :paths ).to_a

      _act.should eql %w( / /file-A /file-B )
    end

    it "occurrence groups" do

      _og_a = _state.occurrence_groups
      _og_a.length.should eql 4
    end

    shared_subject :_state do

      _st = stub_match_stream_session_one_.execute

      o = magnetics_module_::Graph_Structure_via_Match_Stream.new
      o.match_stream = _st
      o.pattern_strings = [ _THING_TWO, _THING_ONE, 'THING_THREE' ]
      o.execute
    end
  end
end
