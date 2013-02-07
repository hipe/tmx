require_relative '../../test-support'


module Skylab::TanMan::TestSupport::API::Actions

  describe "The #{ TanMan::API } action Graph Starter Set", tanman: true,
                                                        api_action: true do

   extend Actions_TestSupport

    action_name [:graph, :starter, :set]

    it "when bad name - \"not found: foo. known starters: bar, baz\" #{
      }(and metadata)" do

      prepare_tanman_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1 @@
        +using_starter=holy-foly.dot
      HERE

      api_invoke_from_tmpdir name: 'zoidberg'

      response.events.length.should eql(1)
      e = response.events.first
      e.stream_name.should eql( :error )
      e.message.should match( /not found: zoidberg, zoidberg\.dot/i )
      e.message.should match( /known starters:/i )
      e.valid_names.should be_kind_of( ::Array )
      e.valid_names.first.should be_kind_of( ::String )
    end


    it "when good name - \"changed from foo to bar\" (no metadata)" do

      prepare_tanman_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1 @@
        +using_starter=hoitus-toitus.dot
      HERE

      api_invoke_from_tmpdir name: 'holy-smack'
      (1..5).should cover(response.events.length)
      e = response.events.first
      e.stream_name.should eql( :info )
      e.message.should match( /chang(?:ing|ed) using_starter from #{
        }"hoitus-toitus\.dot" to "holy-smack\.dot"/i )
    end
  end
end
