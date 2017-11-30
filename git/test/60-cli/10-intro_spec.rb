require_relative '../test-support'

module Skylab::Git::TestSupport

  describe "[gi] CLI - intro", wip: true do

    TS_[ self ]
    use :CLI
    # NOTE when you return to this file, we commented out something in the above file 

    it "CLI client loads" do  # can be moved up when appropriate
      Home_::CLI
    end

    it "ping payload channel (expect STDOUT)" do

      invoke 'ping', 'foo'
      want :o, '(out: foo)'
      want_no_more_lines
      expect( @exitstatus ).to eql :pingback_from_API
    end

    it "ping error channel (expect STDERR)" do

      invoke 'ping', '--channel', 'inf', 'faz'
      want :e, '(inf: faz)'
      want_succeed
    end

    it "ping error channel (expect STDERR)" do

      invoke 'ping', '--channel', 'ero', 'wrong'
      want :e, '(failed because pretending this was wrong: "wrong")'
      want_specific_invite_line_to :ping
      want_fail
    end

    # (mounted one-offs are covered in "integration")
  end
end
