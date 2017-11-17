require_relative 'test-support'

module Skylab::Slicer::TestSupport

  describe "[sli] CLI cannon" do

    TS_[ self ]
    use :want_CLI

    it "1.3" do

      invoke 'ping'
      want :e, "hello from slicer."
      want_no_more_lines
      @exitstatus.should eql :hello_from_slicer
    end

    it "[tmx] integration", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'slicer', 'ping'

      cli.want_on_stderr "hello from slicer.\n"

      cli.want_succeed_under self
    end
  end
end
