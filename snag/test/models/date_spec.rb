require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - date" do

    extend TS_
    use :expect_event

    context 'Date' do

      it "invalid" do

        subject 'foo'
        expect_not_OK_event :invalid_date, 'invalid date: (ick "foo")'
        expect_failed
      end

      it "valid" do

        subject '1234-56-78'
        expect_no_more_events
        @result.value_x.string.should eql '1234-56-78'
      end

      def subject s

        @result = Home_::Models_::Date.normalize_qualified_knownness(
          Common_::Qualified_Knownness.via_value_and_symbol( s, :argument ),
          & handle_event_selectively_ )

        NIL_
      end
    end
  end
end
