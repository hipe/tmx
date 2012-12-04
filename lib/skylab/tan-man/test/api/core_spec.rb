require_relative '../test-support'

module Skylab::TanMan::TestSupport

  describe "The #{ TanMan::API } itself", tanman: true do

    it "is a persistent object" do # #slated for [#030]
      api.should be_trueish
      oid = api.object_id
      api.object_id.should eql(oid)
    end

    context "when you invoke an action with an invalid name" do
      it "it gives you a list-like result whose first event is an appropriate error" do
        response = api.invoke :'not_an_action'
        e = response.events.first
        e.tag.name.should eql(:error)
        e.message.should match(
          /api runtime error : actions has no "not_an_action" action/i )
      end
    end
  end
end
