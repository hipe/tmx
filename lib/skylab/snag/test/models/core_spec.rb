require_relative 'test-support'

module Skylab::Snag::TestSupport::Models

  describe "[cb] models" do

    extend TS_

    context 'Date' do

      it "invalid" do
        subject 'foo'
        expect :error_event, 'invalid date: (ick foo)'
        expect_failed
      end

      it "valid" do
        subject '1234-56-78'
        expect_no_more_events
        @result.should eql '1234-56-78'
      end

      def subject s
        @result = Snag_::Models::Date.normalize s, listener_spy
      end
    end
  end
end
