require_relative 'test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] models" do

    TS_[ self ]
    use :expect_event

    it "ping OK" do

      call_API :ping

      expect_neutral_event :ping, 'hello from (app_name).'

      @result.should eql :hello_from_treemap

      expect_no_more_events
    end

    it "tmx integration (stowaway)", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'treemap', 'ping'

      cli.expect_on_stderr "hello from treemap.\n"

      cli.expect_succeeded_under self
    end
  end
end
