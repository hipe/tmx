require_relative 'test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] models" do

    TS_[ self ]
    use :want_event

    it "ping OK" do

      call_API :ping

      want_neutral_event :ping, 'hello from (app_name_string).'

      @result.should eql :hello_from_treemap

      want_no_more_events
    end

    it "tmx integration (stowaway)", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'treemap', 'ping'

      cli.want_on_stderr "hello from treemap.\n"

      cli.want_succeed_under self
    end
  end
end
