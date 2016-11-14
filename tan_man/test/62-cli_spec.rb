require_relative 'test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] CLI" do

    TS_[ self ]

    # NOTE - apparently we don't have any other modality integration testing?

    it "[tmx] integration (stowaway)" do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'tan-man', 'ping'

      cli.expect_on_stderr "hello from tan man.\n"

      cli.expect_succeeded_under self
    end
  end
end
# #history: moved to here from [tmx] where it was for years
