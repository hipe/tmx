require_relative '../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] operations -  ping" do

    TS_[ self ]
    use :want_event

    it "loads." do

      Home_::API
    end

    it "pings." do

      call_API :ping
    end
  end
end
