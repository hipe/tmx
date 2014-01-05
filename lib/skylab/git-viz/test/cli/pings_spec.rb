require_relative 'test-support'

module Skylab::GitViz::TestSupport::CLI

  describe "[gv] CLI - pings" do

    extend TS__ ; use :expect

    it "just a simple ping" do
      invoke 'ping'
      expect :on_channel_i, :e, HELLO__
      expect_no_more_lines
      @result.should eql :hello_from_git_viz
    end

    it "ping with an option to use the pay channel" do
      invoke 'ping', '--on-channel', 'pay'
      expect :on_channel_i, :o, HELLO__
      expect_no_more_lines
      @result.should eql :hello_from_git_viz
    end

    HELLO__ = 'hello from git viz.'.freeze

  end
end
