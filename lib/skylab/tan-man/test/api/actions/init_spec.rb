require_relative 'test-support'

module Skylab::TanMan::TestSupport::API::Actions

  TanMan::TestSupport::Services::JSON || nil # load it

  describe "The #{ TanMan::API } itself", tanman: true do
    extend Actions_TestSupport

    context "when you invoke a nonexistant action" do
      it "it gives you a list-like result whose first event is an error with a message" do
        response = api_invoke :'not-an-action'
        lone_error response, /not? .*not-an-action/
      end
    end


    context "the #{ TanMan::API } action Init" do
      context "with some bad args" do
        let :event do
          response = api_invoke :init, these: 'are', invalid: 'args'
          response.events.first
        end

        context "event tag name" do
          subject { event.tag.name }
          specify { should eql(:error) }
        end

        context "event message" do
          subject { event.message }
          specify { should match(/invalid action parameters: \(these, invalid\)/) }
        end
      end

      context "with regards to working or not working" do
        before do
          prepare_tanman_tmpdir
        end

        context "when the folder isn't initted" do
          it "works (with json formatting)" do
            response = api_invoke :init, path: TMPDIR
            response.success?.should eql(true)
            event = response.send(:json_data).first
            event[0].should eql(:info)
            event[1].should match(%r{mkdir.+#{ TMPDIR_STEM }/local-conf.d})
            json = ::JSON.pretty_generate response
            unencoded = ::JSON.parse json
            event = unencoded.first
            event[0].should eql('info')
            event[1].should match(%r{mkdir.+#{ TMPDIR_STEM }/local-conf.d})
          end
        end

        context "when the folder already initted" do
          before { prepare_local_conf_dir }
          it "will gracefully give a notice" do
            response = api_invoke :init, path: TMPDIR
            response.events.length.should be_gte(1)
            response.success?.should eql(true)
            e = response.events.first
            e.type.should eql(:skip)
            e.message.should match(/already exists, skipping/i)
          end
        end

        context "when you pass it a path that does not exist" do
          it "it derps" do
            response = api_invoke :init, path: TMPDIR.join('not-exist')
            response.success?.should eql(false)
            e = response.events.first
            e.type.should eql(:error)
            e.message.should match(
              %r{directory must exist:.*#{ TMPDIR_STEM }/not-exist})
          end
        end

        context "when you pass it a path that is a file not a folder" do
          it "it derps" do
            TMPDIR.touch 'nerk'
            response = api_invoke :init, path: TMPDIR.join('nerk')
            response.success?.should eql(false)
            e = response.events.first
            e.type.should eql(:error)
            e.message.should match(
              %r{path was file, not directory: .*tmp/#{ TMPDIR_STEM }})
          end
        end
      end
    end
  end
end
