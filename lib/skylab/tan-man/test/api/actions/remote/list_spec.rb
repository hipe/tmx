require_relative '../../../../api'
require_relative '../../../test-support'

module Skylab::TanMan::TestSupport
  describe "The Remote List method of #{TanMan::Api}" do
    include TanMan::TestSupport
    before { api.clear_cache! }
    context "when there are no conf dirs at all" do
      before { TMPDIR.prepare }
      it "returns an error event explaining the situation" do
        events = api.invoke(%w(remote list))
        lone_error(events, /local conf dir not found/)
      end
    end
    context "where there is a local conf dir" do
      before { prepare_local_conf_dir }
      it "returns an absolutely empty result set when empty" do
        events = api.invoke(%w(remote list))
        events.should be_kind_of(Array) # actually special class, might change
        events.size.should eql(0)
      end
    end
  end
end

