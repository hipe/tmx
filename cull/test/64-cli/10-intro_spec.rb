require_relative '../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] clients - CLI", wip: true do

    TS_[ self ]
    TS_::CLI[ self ]  # (should be `use :CLI` but for ..)

# (1/N)
    it "0   no args" do
      invoke
      want :styled, /\Aexpecting <action>\z/i
      want :styled, /\Ausage: kul <action> \[\.\.\]\z/i
      want_top_invite_line
      want_no_more_lines
      want_exitstatus_for_general_failure
    end

# (2/N)
    it "1.2 strange arg" do
      invoke 'cow'
      want_unrecognized_action :cow
      want :styled, /\Aknown actions are \('ping', 'create'/
      want_top_invite_line
    end

    def want_unrecognized_action sym
      want :e, "unrecognized action #{ sym.id2name.inspect }"
    end

# (3/N)
    it "1.3 easy money" do
      invoke 'ping'
      want "hello from cull."
      want_no_more_lines
      expect( @exitstatus ).to eql :hello_from_cull
    end

# (4/N)
    it "[tmx] integration", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'cull', 'ping'

      cli.want_on_stderr "hello from cull.\n"

      cli.want_succeed_under self
    end

    def want_top_invite_line
      want :styled, /\Ause 'kul -h' for help\z/i
    end
  end
end
