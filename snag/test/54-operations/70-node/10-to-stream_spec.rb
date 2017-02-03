require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operatons - node - to-stream" do

    TS_[ self ]
    use :expect_event

    it "upstream identifer not resolved - you won't see it till you gets" do

      call_API :node, :to_stream,
        :upstream_identifier, Fixture_file_[ :not_there ]

      st = @result
      _x = st.gets
      _x.should  eql false

      expect_not_OK_event :stat_error
    end

    it "uses flyweighting" do

      call_API :node, :to_stream,
        :upstream_identifier, Fixture_file_[ :the_first_manifest ]

      st = @result

      x = st.gets
      oid = x.object_id
      x = x.dup

      x_ = st.gets
      x_.object_id.should eql oid
      x_ = x_.dup

      st.gets.should be_nil
      st.upstream.release_resource  # not necessary

      x.ID.to_i.should eql 1
      x_.ID.to_i.should eql 2

      st = x.body.to_business_row_stream_
      st.gets.s.should eql "[#01]  this line is in\n"
      st.gets.s.should eql " part of the above\n"
      st.gets.should be_nil

      st = x_.body.to_business_row_stream_
      st.gets.s.should eql "[#02] hi\n"
      st.gets.should be_nil
    end

    it "`number_limit`" do

      call_API :node, :to_stream,
        :number_limit, 1,
        :upstream_identifier, _alpha_path

      st = @result
      st.gets.ID.to_i.should eql 5
      st.gets.should be_nil
    end

    it "`identifier` where number is too low" do

      call_API :node, :to_stream,
        :identifier, '-12'

      _em = expect_not_OK_event :expecting_number

      black_and_white( _em.cached_event_value ).should eql(
        "'node-identifier-number-component' #{
         }must be a non-negative integer, had \"-12\"" )

      expect_fail
    end

    it "`identifier` (RESULT SHAPE IS EXPERIMENTAL)" do

      call_API :node, :to_stream,
        :identifier, '0002',
        :upstream_identifier, _alpha_path

      expect_no_events
      st = @result.body.to_business_row_stream_

      st.gets.s.should eql "[#002]       #done wizzle bizzle 2013-11-11\n"
      st.gets.s.should eql "               one more line\n"
    end

    it "`identifier` with suffix" do

      call_API :node, :to_stream,
        :identifier, '98.6',
        :upstream_identifier, _second_manifest

      st = @result.body.to_business_row_stream_
      st.gets.s.should eql "[#98.6]  don't use these\n"
      st.gets.should be_nil
    end

    memoize :_second_manifest do
      Fixture_file_[ :the_second_manifest ]
    end

    def _alpha_path
      Path_alpha_[]
    end
  end
end
