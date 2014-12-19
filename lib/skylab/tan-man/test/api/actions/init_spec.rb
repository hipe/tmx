require_relative 'test-support'

module Skylab::TanMan::TestSupport::API::Actions

  describe "the [ta] API action Init", tanman: true, api_action: true, wip: true do

    extend TS_

    action_name :init

    context "with some bad args" do

      let :event do
        api_invoke these: 'are', invalid: 'args'
        response.events.first
      end

      it "event stream name" do
        event.stream_symbol.should eql :error
      end

      it "event message" do
        x = event.message
        x.should match %r(\binvalid action parameters: \(these, invalid\))
      end
    end

    context "with regards to working or not working" do

      context "when the folder isn't initted" do

        before :each do
          prepare_tanman_tmpdir
        end

        it "works (with json formatting)" do
          api_invoke path: TMPDIR # not *from* tmpdir, path is argument
          response.success?.should eql( true )
          event_a = response.send :json_data
          event = event_a.first
          event[ :stream_symbol ].should eql( :info )
          event[ :shape ].should eql( :textual )
          event[ :payload ].should match( /mkdir local-conf\.d/ )
          _JSON = TestLib_::JSON[]
          json = _JSON.pretty_generate response
          unencoded_a = _JSON.parse json
          unencoded_a.length.should eql( 2 )
          event = unencoded_a[ 0 ]
          event[ 'stream_symbol' ].should eql( 'info' )
          event[ 'shape' ].should eql( 'textual' )
          event[ 'payload' ].should match( /mkdir local-conf\.d/ )
        end
      end

      context "when the folder already initted" do

        before :each do
          prepare_tanman_tmpdir
          prepare_local_conf_dir
        end

        it "will gracefully give a notice" do
          api_invoke path: TMPDIR # not *from* tmpdir
          response.events.length.should be_gte(1)
          response.success?.should eql(true)
          e = response.events.first
          e.stream_symbol.should eql(:skip)
          e.message.should match( /already exists, skipping/i )
        end
      end

      context "when you pass it a path that does not exist" do

        before :each do
          prepare_tanman_tmpdir
        end

        it "it derps" do
          path = TMPDIR.join( 'not-exist' ).to_s
          api_invoke path: path # not *from* tmpdir
          response.success?.should eql(false)
          e = response.events.first
          e.stream_symbol.should eql(:error)
          e.message.should match(
            /directory must exist: not-exist/
          )
        end
      end

      context "when you pass it a path that is a file not a folder" do

        before :each do
          prepare_tanman_tmpdir
        end

        it "it derps" do
          TMPDIR.touch 'nerk'
          api_invoke path: TMPDIR.join('nerk') # not *from* tmpdir
          response.success?.should eql(false)
          e = response.events.first
          e.stream_symbol.should eql(:error)
          e.message.should match(
            /path was file, not directory: nerk/ )
        end
      end
    end
  end
end
