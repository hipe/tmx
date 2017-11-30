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

      _em = want_not_OK_event :error

      _sym = _em.cached_event_value.to_event.terminal_channel_symbol

      :unrecognized_argument == _sym || fail

      want_fail
    end

    it "simple ping" do

      call_API :ping
      want_neutral_event :ping
      expect( @result ).to eql :hello_from_git_viz
    end

    it "ping with parameters - the action receives the actual parameters" do

      call_API :ping, :secret_x, :k

      expect( @result ).to eql "hi: k"
      want_no_more_events
    end
  end
end
