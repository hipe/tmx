require_relative 'test-support'


module Skylab::TanMan::TestSupport::API::Actions

  describe "The #{ TanMan::API } action Remote Rm", tanman: true,
                                                api_action: true do
    extend Actions_TestSupport

    action_name [:remote, :rm]

    it "requires a remote_name, derps on failure" do
      r = api_invoke
      r.success?.should eql(false)
      e = r.events.first
      e.type.should eql(:error)
      e.message.should match( /missing required attribute.*remote_name/ )
    end
  end
end
