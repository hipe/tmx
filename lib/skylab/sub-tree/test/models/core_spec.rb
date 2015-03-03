require_relative '../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] models (core)" do

    Callback_.test_support::Expect_event[ self ]

    extend TS_

    it "loads." do

      SubTree_::API

    end

    it "pings." do

      call_API :ping

    end
  end
end
