require_relative 'test-support'

module Skylab::Slicer::TestSupport

  describe "[sli] CLI cannon" do

    TS_[ self ]
    use :expect_CLI

    it "1.3" do

      invoke 'ping'
      expect :e, "hello from slicer."
      expect_no_more_lines
      @exitstatus.should eql :hello_from_slicer
    end

    it "[tmx] integration", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'slicer', 'ping'

      cli.expect_on_stderr "hello from slicer.\n"

      cli.expect_succeed_under self
    end
  end
end
