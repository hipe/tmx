require_relative 'test-support'


module Skylab::TanMan::TestSupport::API::Actions

  describe "The #{ TanMan::API } action Remote List", tanman: true,
                                                  api_action: true do
    extend Actions_TestSupport

    action_name [:remote, :list]

    before do
      prepare_tanman_tmpdir
    end

    context "when there are no conf dirs at all" do
      before { prepared_tanman_tmpdir }
      it "returns an error event explaining the situation" do
        api_invoke
        lone_error( /local conf dir not found/ )
      end
    end

    context "where there is a local conf dir" do
      before { prepare_local_conf_dir }
      it "returns an enumerator result, no events" do
        api_invoke
        response.events.length.should eql(0)
        res_a = response.result.to_a
        res_a.length.should eql(0)
      end
    end
  end
end
