require_relative 'test-support'

module Skylab::Cull::TestSupport::Clients_CLI

  describe "[cu] clients - CLI" do

    extend TS_

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
      expect :styled, /\Aunrecognized action 'cow'\z/i
      expect :styled, /\Aknown actions are \('ping', 'create'/
      expect_top_invite_line
    end

    it "1.3 easy money" do
      invoke 'ping'
      expect "hello from cull."
      expect_no_more_lines
      @exitstatus.should eql :hello_from_cull
    end

    def expect_top_invite_line
      expect :styled, /\Ause 'kul -h' for help\z/i
    end
  end
end
