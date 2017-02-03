require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] operations - intro" do

    TS_[ self ]
    use :reactive_model

    it "loads" do
      Home_::API
    end

    it "ping with strange parameters - emits expression of failure" do

      call_API :ping, :not_an_arg, :_no_see_

      _em = expect_not_OK_event :error

      _sym = _em.cached_event_value.to_event.terminal_channel_symbol

      :extra_properties == _sym or fail

      expect_fail
    end

    it "simple ping" do

      call_API :ping
      expect_neutral_event :ping
      @result.should eql :hello_from_git_viz
    end

    it "ping with parameters - the action receives the actual parameters" do

      call_API :ping, :secret_x, :k

      @result.should eql "hi: k"
      expect_no_more_events
    end
  end
end
