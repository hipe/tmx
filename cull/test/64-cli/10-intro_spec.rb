require_relative '../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] clients - CLI" do

    TS_[ self ]
    use :CLI

    it "0   no args" do
      invoke
      expect :styled, /\Aexpecting <action>\z/i
      expect :styled, /\Ausage: kul <action> \[\.\.\]\z/i
      expect_top_invite_line
      expect_no_more_lines
      expect_exitstatus_for_general_failure
    end

    it "1.2 strange arg" do
      invoke 'cow'
      expect_unrecognized_action :cow
      expect :styled, /\Aknown actions are \('ping', 'create'/
      expect_top_invite_line
    end

    def expect_unrecognized_action sym
      expect :e, "unrecognized action #{ sym.id2name.inspect }"
    end

    it "1.3 easy money" do
      invoke 'ping'
      expect "hello from cull."
      expect_no_more_lines
      @exitstatus.should eql :hello_from_cull
    end

    it "[tmx] integration", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'cull', 'ping'

      cli.expect_on_stderr "hello from cull.\n"

      cli.expect_succeeded_under self
    end

    def expect_top_invite_line
      expect :styled, /\Ause 'kul -h' for help\z/i
    end
  end
end
