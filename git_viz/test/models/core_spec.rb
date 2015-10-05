require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] models" do

    extend TS_
    use :reactive_model_support

    it "loads" do
      Home_::API
    end

    it "ping with strange parameters - emits expression of failure" do

      call_API :ping, :not_an_arg, :_no_see_
      expect_not_OK_event :extra_properties
      expect_failed
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
