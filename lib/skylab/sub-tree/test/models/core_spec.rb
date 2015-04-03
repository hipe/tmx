require_relative '../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] models (core)" do

    extend TS_
    use :expect_event

    it "loads." do

      SubTree_::API

    end

    it "pings." do

      call_API :ping

    end
  end
end
