require_relative '../api'
require_relative 'test-support'

module Skylab::TanMan::TestSupport
  describe TanMan::Api, tanman: true do
    it "is a persistent object" do
      api.should be_trueish
      oid = api.object_id
      api.object_id.should eql(oid)
    end
    context "when you invoke an action with an invalid name" do
      it "it gives you a list-like result whose first event is an appropriate error" do
        events = api.invoke(:'not_an_action')
        events.first.tap do |e|
          e.tag.name.should eql(:error)
          e.message.should match(/invalid action name part: not_an_action/)
        end
      end
    end
  end
end

