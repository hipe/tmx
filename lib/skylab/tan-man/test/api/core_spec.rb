require_relative 'test-support'

module Skylab::TanMan::TestSupport::API

  describe "[tm] API", tanman: true, wip: true do

    extend TS_

    it "is a persistent object" do
      ( !! api ).should eql( true )  # api.should be_trueish
      oid = api.object_id
      api.object_id.should eql( oid )
    end

    context "when you invoke an action with an invalid name" do
      it "the first event in the response events is an appropriate error" do
        response = api.invoke :'not_an_action'
        e = response.events.first
        e.stream_name.should eql( :error )
        e.message.should match(
          /api name error : actions has no "not_an_action" action/i )
      end
    end
  end
end
