require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - intro" do

    TS_[ self ]
    # use :expect_event

    it "no such action", wip: true do
      call_API
      expect_not_OK_event :no_such_action
      expect_failed
    end

    it "ping", wip: true do
      call_API :ping
      expect_OK_event :ping, 'ping (highlight "!")'
      @result.should eql :_hello_from_doc_test_
      expect_no_more_events
    end
  end
end
