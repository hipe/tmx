require_relative '../../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] tally - 2 - 3: match stream via vendor match stream" do

    TS_[ self ]
    use :memoizer_methods
    use :models_tally_magnetics

    it "loads" do
      _subject
    end

    context "(6 matches of 2 patterns in two files)" do

      shared_subject :_state do

        o = stub_match_stream_session_one_
        _state_me o.execute
      end

      it "the first match on the first matching line" do
        _ 0, _FILE_A, 3, _THING_ONE, 14
      end

      it "the second match on the first matching line" do
        _ 1, _FILE_A, 3, _THING_TWO, 28
      end

      it "the match on the second matching line (is at line head)" do
        _ 2, _FILE_A, 6, _THING_TWO, 0
      end

      it "the match on the third matching line (is at line tail)" do
        _ 3, _FILE_A, 9, _THING_ONE, 19
      end

      it "the match in the other file (two items on one line)" do

        _ 4, _FILE_B, 2, _THING_ONE, 5
        _ 5, _FILE_B, 2, _THING_TWO, 19
      end

      it "no other matches" do
        _state.length.should eql 6
      end
    end

    _WIDTH = 'THING_ONE'.length

    define_method :_ do |match_index, path, lineno, pattern_string, range_begin|

      ma = _state.fetch match_index
      ma.path.should eql path
      ma.lineno.should eql lineno
      ma.pattern_string.should eql pattern_string
      _r = range_begin ... ( range_begin + _WIDTH )
      ma.range.should eql _r
    end

    def _state_me st

      st.to_a.freeze
    end

    def _subject
      magnetics_module_::Match_Stream_via_Vendor_Match_Stream
    end
  end
end
