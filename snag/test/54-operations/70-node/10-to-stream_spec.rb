require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operatons - node - to-stream" do

    TS_[ self ]
    use :want_event

    it "upstream identifer not resolved - you won't see it till you gets" do

      call_API :node, :to_stream,
        :upstream_reference, Fixture_file_[ :not_there ]

      st = @result
      _x = st.gets
      expect( _x ).to eql false

      want_not_OK_event :stat_error
    end

    it "uses flyweighting" do

      call_API :node, :to_stream,
        :upstream_reference, Fixture_file_[ :the_first_manifest ]

      st = @result

      x = st.gets
      oid = x.object_id
      x = x.dup

      x_ = st.gets
      expect( x_.object_id ).to eql oid
      x_ = x_.dup

      expect( st.gets ).to be_nil
      st.upstream.release_resource  # not necessary

      expect( x.ID.to_i ).to eql 1
      expect( x_.ID.to_i ).to eql 2

      st = x.body.to_business_row_stream_
      expect( st.gets.s ).to eql "[#01]  this line is in\n"
      expect( st.gets.s ).to eql " part of the above\n"
      expect( st.gets ).to be_nil

      st = x_.body.to_business_row_stream_
      expect( st.gets.s ).to eql "[#02] hi\n"
      expect( st.gets ).to be_nil
    end

    it "`number_limit`" do  # #lends-coverage to [#fi-008.3]

      call_API :node, :to_stream,
        :number_limit, 1,
        :upstream_reference, _alpha_path

      st = @result
      expect( st.gets.ID.to_i ).to eql 5
      expect( st.gets ).to be_nil
    end

    it "`identifier` where number is too low" do

      # #lends-coverage to [#fi-008.12]

      call_API :node, :to_stream,
        :identifier, '-12'

      _em = want_not_OK_event :expecting_number

      expect( black_and_white _em.cached_event_value ).to eql(
        "'node-identifier-number-component' #{
         }must be a non-negative integer, had \"-12\"" )

      want_fail
    end

    it "`identifier` (RESULT SHAPE IS EXPERIMENTAL)" do

      call_API :node, :to_stream,
        :identifier, '0002',
        :upstream_reference, _alpha_path

      want_no_events
      st = @result.body.to_business_row_stream_

      expect( st.gets.s ).to eql "[#002]       #done wizzle bizzle 2013-11-11\n"
      expect( st.gets.s ).to eql "               one more line\n"
    end

    it "`identifier` with suffix" do

      call_API :node, :to_stream,
        :identifier, '98.6',
        :upstream_reference, _second_manifest

      st = @result.body.to_business_row_stream_
      expect( st.gets.s ).to eql "[#98.6]  don't use these\n"
      expect( st.gets ).to be_nil
    end

    memoize :_second_manifest do
      Fixture_file_[ :the_second_manifest ]
    end

    def _alpha_path
      Path_alpha_[]
    end
  end
end
