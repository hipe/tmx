require_relative '../../../../api'
require_relative '../../../test-support'

module Skylab::TanMan::TestSupport
  describe "The Remote Rm method of #{TanMan::Api}" do
    include TanMan::TestSupport
    it "requires a remote_name, derps on failure" do
      ee = api.invoke([:remote, :rm])
      ee.success?.should eql(false)
      ee.first.tap do |e|
        e.type.should eql(:error)
        e.message.should match(/missing required attribute.*remote_name/)
      end
    end
  end
end

