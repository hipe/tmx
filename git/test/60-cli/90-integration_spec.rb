require_relative '../test-support'

module Skylab::Git::TestSupport

  describe "[gi] CLI - integration", TMX_CLI_integration: true do

    TS_[ self ]

    it "ping the top" do

      cli = _same

      cli.invoke 'git', 'ping'

      cli.expect_on_stderr "hello from git.\n"

      cli.expect_succeeded_under self
    end

    it "citxt" do

      cli = _same

      cli.invoke 'git', 'citxt', '--ping'

      cli.expect_on_stderr "hello from citxt."

      cli.expect_succeeded_under self
    end

    it "breakup" do

      cli = _same

      cli.invoke 'git', 'breakup', '--ping'

      cli.expect_on_stderr "hello from breakup."

      cli.expect_succeeded_under self
    end

    it "uncommit" do

      cli = _same

      cli.invoke 'git', 'uncommit', '--ping'

      cli.expect_on_stderr "hello from uncommit."

      cli.expect_succeeded_under self
    end

    def _same

      Home_::Autoloader_.require_sidesystem :TMX

      ::Skylab::TMX.test_support.begin_CLI_expectation_client
    end
  end
end
# #history: moved to its own file (years later) when disincorporating from [tmx]
