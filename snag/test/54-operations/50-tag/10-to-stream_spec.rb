require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - tag - to-stream", wip: true do

    TS_[ self ]
    use :want_event
    use :byte_up_and_downstreams

    context "(with this manifest)" do

      it "we need a valid node identifier (node model is used painlessly)" do

        call_API :tag, :to_stream,
          :upstream_reference, :xxx,
          :node_identifier, 'Xxx'

        _em = want_not_OK_event :expecting_number

        expect( black_and_white _em.cached_event_value ).to eql(
          "'node-identifier-number-component' #{
           }must be a non-negative integer, had \"Xxx\"" )

        want_fail
      end

      it "ok with two tags" do

        call_API(
          :tag, :to_stream,
          :upstream_reference, Fixture_file_[ :the_sutherlands_mani ],
          :node_identifier, 1,
          & EMPTY_P_ )

        st = @result
        o = st.gets
        expect( o.intern ).to eql :one

        o = st.gets
        expect( o.intern ).to eql :two

        expect( st.gets ).to be_nil
      end
    end

    context "take this" do

      it "x." do

        _us_id = upstream_reference_via_string_ <<-O
[#77] ( #fml: x
 y ) no see ( #fml: z )
        O

        call_API :tag, :to_stream,
          :upstream_reference, _us_id,
          :node_identifier, 77, & EMPTY_P_

        st = @result

        o = st.gets

        expect( o.get_string ).to eql "( #fml: x\n y )"
        expect( o.get_name_string ).to eql '#fml'
        expect( o.get_value_string ).to eql " x\n y "

        o = st.gets

        expect( o.get_string ).to eql "( #fml: z )"
        expect( o.get_name_string ).to eql '#fml'
        expect( o.get_value_string ).to eql ' z '

        expect( st.gets ).to be_nil
      end
    end
  end
end
