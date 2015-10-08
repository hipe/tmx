require_relative '../test-support'

module Skylab::TanMan::TestSupport::API::Actions

  describe "[tm] API action Remote List", tanman: true, api_action: true, wip: true do

    extend TS_

    action_name [:remote, :list]

    context "when there are no conf dirs at all" do

      before :each do
        prepared_tanman_tmpdir
      end

      it "result is an error event explaining the situation" do
        api_invoke
        lone_error( /local conf dir not found/ )
      end
    end

    context "where there is a local conf dir" do

      before :each do
        prepare_tanman_tmpdir
        prepare_local_conf_dir
      end

      it "result is an enumerator, no events" do
        api_invoke
        response.events.length.should eql(0)
        res_a = response.result.to_a
        res_a.length.should eql(0)
      end
    end
  end
end
