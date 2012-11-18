require_relative 'test-support'

module Skylab::TanMan::TestSupport::API::Actions
  describe "The #{TanMan::API} itself", tanman: true do
    extend Actions_TestSupport
    context "when you invoke a nonexistant action" do
      it "it gives you a list-like result whose first event is an error with a message" do
        events = api_invoke(:'not-an-action')
        lone_error(events, /not? .*not-an-action/)
      end
    end
    context "the #{TanMan::API} action Init" do
      context "with some bad args" do
        let(:event) do
          events = api_invoke(:init, these: 'are', invalid: 'args')
          events.first
        end
        context "event tag name" do
          subject { event.tag.name }
          specify { should eql(:error) }
        end
        context "event message" do
          subject { event.message }
          specify { should match(/invalid action parameters\(s\): \(these, invalid\)/) }
        end
      end
      context "with regards to working or not working" do
        before do
          prepare_submodule_tmpdir
        end
        context "when the folder isn't initted" do
          it "works (with json formatting)" do
            events = api_invoke(:init, :path => TMPDIR)
            events.success?.should eql(true)
            event = events.json_data.first
            event[0].should eql(:info)
            event[1].should match(%r{mkdir.+#{TMPDIR_STEM}/local-conf.d})
            events = JSON.parse(JSON.pretty_generate(events))
            event = events.first
            event[0].should eql('info')
            event[1].should match(%r{mkdir.+#{TMPDIR_STEM}/local-conf.d})
          end
        end
        context "when the folder already initted" do
          before { prepare_local_conf_dir }
          it "will gracefully give a notice" do
            events = api_invoke(:init, path: TMPDIR)
            events.size.should be_gte(1)
            events.success?.should eql(true)
            events.first.tap do |e|
              e.type.should eql(:skip)
              e.message.should match(/already exists, skipping/i)
            end
          end
        end
        context "when you pass it a path that does not exist" do
          it "it derps" do
            events = api_invoke(:init, path: TMPDIR.join('not-exist'))
            events.success?.should eql(false)
            events.first.tap do |e|
              e.type.should eql(:error)
              e.message.should match(
                %r{directory must exist:.*#{TMPDIR_STEM}/not-exist})
            end
          end
        end
        context "when you pass it a path that is a file not a folder" do
          it "it derps" do
            TMPDIR.touch('nerk')
            events = api_invoke(:init, path: TMPDIR.join('nerk'))
            events.success?.should eql(false)
            events.first.tap do |e|
              e.type.should eql(:error)
              e.message.should match(
                %r{path was file, not directory: .*tmp/#{TMPDIR_STEM}})
            end
          end
        end
      end
    end
  end
end

