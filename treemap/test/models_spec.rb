require_relative 'test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] models" do

    TS_[ self ]
    use :expect_event

    it "ping OK" do

      call_API :ping

      expect_neutral_event :ping, 'hello from (app_name).'

      @result.should eql :hello_from_treemap

      expect_no_more_events
    end
  end
end
