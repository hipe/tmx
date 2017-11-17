require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - date" do

    TS_[ self ]
    use :want_event

    # -
      it "invalid" do

        subject 'foo'
        want_not_OK_event :invalid_date, 'invalid date: (ick "foo")'
        want_fail
      end

      it "valid" do

        subject '1234-56-78'
        want_no_more_events
        @result.value.string.should eql '1234-56-78'
      end

      def subject s

        @result = Home_::Models_::Date.normalize_qualified_knownness(
          Common_::QualifiedKnownKnown.via_value_and_symbol( s, :argument ),
          & handle_event_selectively_ )

        NIL_
      end

      def subject_API_value_of_failure
        false  # #open [#007.B]
      end

    # -
  end
end
