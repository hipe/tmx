require_relative '../test-support.rb'

module Skylab::TanMan::TestSupport::API::Actions::Graph

  describe "[ta] api actions graph starter list" do

    extend TS__

    action_name %i( graph starter list )

    it "ok" do
      wat = api_invoke
      ( 2..4 ).should be_include( wat.events.length )
      r = wat.events.detect do |x|
        /\A[-a-z]+\.dot\z/ !~ x.message
      end
      r.should eql( nil )
    end
  end
end
