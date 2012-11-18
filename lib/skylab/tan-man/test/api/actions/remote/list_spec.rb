require_relative 'test-support'

module Skylab::TanMan::TestSupport::API::Actions
  describe "The #{TanMan::API} action Remote List", tanman: true do
    extend Actions_TestSupport
    before { api.clear }
    context "when there are no conf dirs at all" do
      before { prepared_submodule_tmpdir }
      it "returns an error event explaining the situation" do
        events = api_invoke(%w(remote list))
        lone_error(events, /local conf dir not found/)
      end
    end
    context "where there is a local conf dir" do
      before { prepare_local_conf_dir }
      it "returns an absolutely empty result set when empty" do
        events = api_invoke(%w(remote list))
        events.should be_kind_of(Array) # actually special class, might change
        events.size.should eql(0)
      end
    end
  end
end
