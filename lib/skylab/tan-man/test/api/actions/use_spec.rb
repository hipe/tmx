require_relative 'test-support'


module Skylab::TanMan::TestSupport::API::Actions

  # *NOTE* these tests really do create files so it is vital that
  # you make sure to cd into the tmpdir (blown away and recreated for us
  # on calls to `prepare_tanman_tmpdir`) for now!

  describe "The #{ TanMan::API } action Use", tanman: true,
                                          api_action: true do

    extend Actions_TestSupport

    action_name [:use]

    context "when we are not initted" do

      before do
        prepare_tanman_tmpdir
      end

      it '*and* you give it no args - "missing the required parameter .."' do
        api_invoke
        lone_error( /missing the required parameter.+path\b/ )
      end

      it 'and you give an arg - "local conf dir not found"' do
        from_tmpdir do
          api_invoke path: 'some-path'
        end
        e = response.events.first
        e.type.should eql(:no_config_dir)
        e.message.should match( /local conf dir not found/ )
      end
    end


    context "when we are initted" do

      before do
        prepare_local_conf_dir
      end

      it 'and you give it a path in a directory that does *not* exist - ".."' do
        from_tmpdir do
          api_invoke path: 'some-deep/path'
        end
        response.error.message.should match( # maybe an :info was emitted before
          /cannot create, directory does not exist.+some-deep/i
        )
        response.result.should eql(false)
      end


      context "and you give it a path in a directory that *does* exist" do

        it 'and you give it a path that *is* a dirctory - "is directory" ' do
          prepared_tanman_tmpdir.mkdir 'is-a-directory.dot' # CONTRIVED
          from_tmpdir do
            api_invoke path: 'is-a-directory.dot'
          end
          lone_error( /cannot create, is directory: is-a-directory\.dot/i )
        end

        it 'and you give it a path that is a file - "file exists" ' do
          prepared_tanman_tmpdir.touch 'hi-im-here.dot'
          from_tmpdir do
            api_invoke path: 'hi-im-here.dot'
          end
        end

        context 'and you give it a path that does *not* exist' do
          it 'and the path does *not* have an extension - adds one, makes' do
            from_tmpdir do
              api_invoke path: 'what-a-good-path'
            end
            response.should be_success
            response.events.first.message.should match(
              /adding \.dot extension/ )
            tanman_tmpdir.join('what-a-good-path.dot').should be_exist
          end

          it 'and the path *does* have an extension - makes file' do
            from_tmpdir do
              api_invoke path: 'what-a-nice-path.dot'
            end
            response.should be_success
            response.events.first.message.should match(
              /wrote what-a-nice-path\.dot/ )
            tanman_tmpdir.join('what-a-nice-path.dot').should be_exist
          end
        end
      end
    end
  end
end
