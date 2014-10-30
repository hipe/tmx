require_relative 'test-support'

module Skylab::GitViz::TestSupport::API

  describe "[gv] API" do

    extend TS__ ; use :expect

    it "loads" do
      GitViz_::API
    end

    it "ping with strange parameters - X" do
      -> do
        invoke_API :ping, :not_an_arg, :_no_see_
      end.should raise_error ::ArgumentError,
        /\Aunexpected iambic term 'not_an_arg'\z/
    end

    it "simple ping" do
      invoke_API :ping
      expect :on_channel_i, :info, "hello from git viz."
      expect_no_more_emissions
      @result.should eql :hello_from_git_viz
    end

    it "ping with parameters, defaults" do
      invoke_API :ping, :go_the_distance, :how_wide, "20 feet"
      expect :on_channel_i, :info, '(20 feet x 80 feet)'
      @result.should eql :_the_distance_
    end
  end
end
