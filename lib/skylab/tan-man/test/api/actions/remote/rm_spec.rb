require_relative 'test-support'

module Skylab::TanMan::TestSupport::API::Actions
  describe "The #{TanMan::API} action Remote Rm", tanman: true do
    extend Actions_TestSupport
    it "requires a remote_name, derps on failure" do
      ee = api_invoke([:remote, :rm])
      ee.success?.should eql(false)
      ee.first.tap do |e|
        e.type.should eql(:error)
        e.message.should match(/missing required attribute.*remote_name/)
      end
    end
  end
end

