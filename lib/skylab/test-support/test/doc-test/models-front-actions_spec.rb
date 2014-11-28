require_relative 'test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - models - front - actions" do

    TestLib_::Expect_event[ self ]

    extend TS_

    it "no such action" do
      call_API
      expect_not_OK_event :no_such_action
      expect_failed
    end

    it "ping" do
      call_API :ping
      expect_OK_event :ping, 'ping (highlight "!")'
      @result.should eql :_hello_from_doc_test_
      expect_no_more_events
    end

    def subject_API
      Subject_[]::API
    end
  end
end
