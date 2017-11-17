require_relative 'test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] CLI", wip: true do

    TS_[ self ]

    # NOTE - apparently we don't have any other modality integration testing?

    it "[tmx] integration (stowaway)", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'tan-man', 'ping'

      cli.want_on_stderr "hello from tan man.\n"

      cli.want_succeed_under self
    end
  end
end
# #history: moved to here from [tmx] where it was for years
