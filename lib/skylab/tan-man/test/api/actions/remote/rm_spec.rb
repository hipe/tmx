require_relative '../test-support'

module Skylab::TanMan::TestSupport::API::Actions

  describe "[tm] API action Remote Rm", tanman: true, api_action: true, wip: true do

    extend TS_

    action_name [:remote, :rm]

    it "requires a remote_name, derps on failure" do
      r = api_invoke
      r.success?.should eql(false)
      e = r.events.first
      e.stream_name.should eql(:error)
      e.message.should match( /missing required attribute.*remote_name/ )
    end
  end
end
