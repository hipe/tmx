require_relative 'test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models" do

    TS_[ self ]
    use :expect_event

    it "loads" do

      Home_::Models_
    end

    it "pings" do

      call_API :ping
      expect_neutral_event :ping, "hello from snag."
      @result.should eql :hello_from_snag
    end
  end
end
