require_relative 'test-support'

::Skylab::TestSupport::Quickie.enable_kernel_describe

module Skylab::TanMan::TestSupport::API::Actions

  describe "The #{ TanMan::API } action Remote Add", tanman: true,
                                                 api_action: true do

    extend Actions_TestSupport

    action_name [:remote, :add]

    context "when there is no local conf directory" do

      before :each do
        prepare_tanman_tmpdir
      end

      it "requires certain args, derps on failure" do
        response = api_invoke
        lone_error( /missing required attribute.*"host".*"name"/ )
        response.success?.should eql( false )
      end

      it "result is an error event if it cannot find the local config dir" do
        response = api_invoke name: 'flip', host: 'flap'
        response.success?.should eql(false)
        lone_error( /local conf dir not found/i )
      end
    end


    context "when you have a local config dir" do

      before :each do
        prepare_local_conf_dir
      end

      it "an invalid remote derps (host with space)" do
        response = api_invoke name: 'floop', host: 'space case'
        lone_error( /"space case" did not match pattern for url/ )
        response.success?.should eql( false )
      end

      it "adding a valid local remote works (confirmed with a second api call)" do
        response = api_invoke name: 'flip', host: 'flap'
        lone_success(
          /\Acreating config \.\. done \(146 bytes\.\)\n\z/ )

        response = api_invoke_action [:remote, :list]
        response.should be_success
        a = response.result.to_a # [#048]
        a.length.should eql(1)
        x = a.first
        d = x.to_a
        d.should eql(['flip', 'flap'])
      end

      it "you can add a valid global remote (json! JSON!)" do
        response = api_invoke name: 'fliz', host: 'flaz', resource: 'global'
        lone_success(
          /\Acreating global-conf-file \.\. done \(146 bytes\.\)\n\z/ )
        response = api_invoke_action [:remote, :list]
        response.should be_success
        a = response.result.to_a  # [#048]
        a.length.should eql(1)
        a = a.to_a
        a.map!(&:to_a) # omg i'm so sorry
        TanMan::TestSupport::Services::JSON || nil # ack!
        json = a.to_json
        rows = TanMan::TestSupport::Services::JSON.parse json
        rows.length.should eql(1)
        rows.first.should eql(['fliz', 'flaz'])
      end
    end
  end
end
