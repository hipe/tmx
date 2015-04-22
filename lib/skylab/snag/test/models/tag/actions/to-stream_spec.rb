require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - tag - actions - to-stream" do

    extend TS_
    use :expect_event

    context "(with this manifest)" do

      it "we need a valid node identifier (node model is used painlessly)" do

        call_API :tag, :to_stream,
          :upstream_identifier, :xxx,
          :node_identifier, 'Xxx'

        _ev = expect_not_OK_event :uninterpretable_under_number_set

        black_and_white( _ev ).should eql(
          "'node-identifier-number-component' #{
           }must be a non-negative integer, had 'Xxx'" )

        expect_failed
      end

      it "ok with two tags" do

        call_API :tag, :to_stream,
          :upstream_identifier, Fixture_file_[ :the_sutherlands_mani ],
          :node_identifier, 1, & EMPTY_P_

        st = @result
        o = st.gets
        o.intern.should eql :one

        o = st.gets
        o.intern.should eql :two

        st.gets.should be_nil
      end
    end
  end
end
