require_relative 'test-support'


module Skylab::TanMan::TestSupport::API::Actions

  describe "The #{ TanMan::API } action Remote List", tanman: true do
    extend Actions_TestSupport

    before { services_clear }

    context "when there are no conf dirs at all" do
      before { prepared_submodule_tmpdir }
      it "returns an error event explaining the situation" do
        response = api_invoke(%w(remote list))
        lone_error( response, /local conf dir not found/ )
      end
    end

    context "where there is a local conf dir" do
      before { prepare_local_conf_dir }
      it "returns an enumerator result, no events" do
        response = api_invoke(%w(remote list))
        response.events.length.should eql(0)
        res_a = response.result.to_a
        res_a.length.should eql(0)
      end
    end
  end
end
