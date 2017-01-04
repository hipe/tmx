require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - mount one-offs ", wip: true do

    TS_[ self ]

    it "shallowify" do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = TS_.begin_CLI_expectation_client

      cli.invoke 'shallowify', '--ping'

      cli.expect_on_stderr "hello from shallowify"

      cli.expect_succeeded_under self
    end

    # #todo - the test above replaces a test from [tmx] that tested the
    # "xargs-ish-i" script, which is very legacy and of dubious enduring
    # utility. the same characterization applies to all of these scripts,
    # to greater or lesser degrees. we have chosen to cover "shallowify"
    # because it is the one script we still use one in a while, with the
    # exception of "no-line-breaks" which explains its own obsolescence
    # there.
    #
    #   - also "partition" has been useful lately
    #
    # at writing, all FIVE (5) other scripts showed their help screens
    # when invoked through mounting. we haven't covered them here mainly
    # for the reasons above

  end
end
