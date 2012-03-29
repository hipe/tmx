require_relative '../../../../api'
require_relative '../../../test-support'

module Skylab::TanMan::TestSupport
  describe "The Remote Add method of #{TanMan::Api}" do
    let(:name) { [:remote, :add] }

    include TanMan::TestSupport
    context "when there is no local conf directory" do
      before do
        TMPDIR.prepare
      end
      it "requires certain args, derps on failure" do
        ee = api.invoke(%w(remote add))
        lone_error ee, /missing required attribute.*"host".*"name"/
      end
      it "returns an error event if it cannot find the local config dir, (undecorated message)" do
        ee = api.invoke(name, name: 'flip', host: 'flap')
        lone_error ee, /local conf dir not found/i
      end
    end
    context "when you have a local config dir" do
      before do
        api.clear_cache!
        prepare_local_conf_dir
      end
      it "an invalid remote derps (host with space)" do
        ee = api.invoke(name, name: 'floop', host: 'space case')
        lone_error ee, /"space case" did not match pattern for url/
      end
      it "adding a valid local remote works (confirmed with a second api call)" do
        ee = api.invoke(name, name: 'flip', host: 'flap')
        lone_success ee, %r{\bcreating.*tanman/local-conf\.d/config.*\.\..*\(\d{2,} bytes\b}
        (ee = api.invoke([:remote, :list])).should be_success
        ee.size.should eql(1)
        (h = ee.first.payload).should be_kind_of(Hash)
        h[:row_data].should eql(['flip', 'flap'])
      end
      it "you can add a valid global remote (confirmed with seconds api call un-jsonized)" do
        ee = api.invoke(name, name: 'fliz', host: 'flaz', resource: 'global')
        lone_success ee, %r{\bcreating.*tanman/global-conf-file.*\(\d{2,} bytes\b}
        (ee = api.invoke([:remote, :list])).should be_success
        rows = JSON.parse(ee.to_json)
        rows.size.should eql(1)
        rows.first[1]['row_data'].should eql(['fliz', 'flaz'])
      end
    end
  end
end

