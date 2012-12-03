require_relative 'test-support'
require 'json' # #[#042] sas


module Skylab::TanMan::TestSupport::API::Actions

  describe "The #{ TanMan::API } action Remote Add", tanman: true do

    extend Actions_TestSupport

    let(:name) { [:remote, :add] }


    context "when there is no local conf directory" do

      before do
        prepare_submodule_tmpdir
      end

      it "requires certain args, derps on failure" do
        response = api_invoke ['remote', 'add'] # strings just for fun
        lone_error response, /missing required attribute.*"host".*"name"/
      end

      it "returns an error event if it cannot find the local config dir" do
        response = api_invoke name, name: 'flip', host: 'flap'
        response.success?.should eql(false)
        lone_error response, /local conf dir not found/i
      end
    end


    context "when you have a local config dir" do

      before do
        services_clear
        prepare_local_conf_dir
      end

      it "an invalid remote derps (host with space)" do
        response = api_invoke name, name: 'floop', host: 'space case'
        lone_error response, /"space case" did not match pattern for url/
      end

      it "adding a valid local remote works (confirmed with a second api call)" do
        response = api_invoke name, name: 'flip', host: 'flap'
        lone_success response,
          %r{\bcreating.*#{ TMPDIR_STEM
          }/local-conf\.d/config.*\.\..*\(\d{2,} bytes\b}

        response = api_invoke [:remote, :list]
        response.should be_success
        a = response.result.to_a # FIXME [#048]
        a.length.should eql(1)
        x = a.first
        d = x.to_a
        d.should eql(['flip', 'flap'])
      end

      it "you can add a valid global remote (json! JSON!)", wip: true do
        response = api_invoke name, name: 'fliz', host: 'flaz',
                                    resource: 'global'
        lone_success response,
          %r{\bcreating.*#{ TMPDIR_STEM }/global-conf-file.*\(\d{2,} bytes\b}
        response = api_invoke [:remote, :list]
        response.should be_success
        a = response.result.to_a # FIXME [#048]
        a.length.should eql(1)
        a = a.to_a
        a.map!(&:to_a) # omg i'm so sorry
        json = a.to_json
        rows = ::JSON.parse json
        rows.length.should eql(1)
        rows.first.should eql(['fliz', 'flaz'])
      end
    end
  end
end
