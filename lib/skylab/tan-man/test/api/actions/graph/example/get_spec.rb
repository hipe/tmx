require_relative '../../test-support'


module Skylab::TanMan::TestSupport::API::Actions

  describe "The #{ TanMan::API } action Graph Example Get", tanman: true,
                                                        api_action: true do

   extend Actions_TestSupport

    action_name [:graph, :example, :get]

    it "when set - \"example is set to \"holy-nerp.dot\" in local config #{
      }file\" (and tons of metadata)" do

      prepare_tanman_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1 @@
        +using_example=holy-nerp.dot
      HERE

      api_invoke_from_tmpdir
      response.events.length.should eql(1)
      e = response.events.first
      e.type.should eql(:info)
      e.message.should eql(
        'example is set to "holy-nerp.dot" in local config file.')
      e.meta.value_was_set.should eql(true)
      e.meta.searched_resources.length.should eql(1)
    end


    it "when not set - \"there is no example set in local config file or #{
      }global config file\" (and metadata)"  do
      prepare_tanman_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1 @@
        +EXOMPLIE = holy-foly.dot
      HERE
      api_invoke_from_tmpdir
      response.events.length.should eql(1)
      e = response.events.first
      e.type.should eql(:info)
      e.message.should eql(
        "there is no example set in local config file or global config file" )
      (!! e.meta.value_was_set).should eql(false)
      e.meta.searched_resources.length.should eql(2) # two this time, no
    end                                        # short circuit
  end
end
