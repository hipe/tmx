require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI

  describe "[br] CLI cannon" do

    extend TS_

    it "  0)  no arguments - error / usage / invite" do
      invoke
      expect :styled, 'expecting <action>'
      expect_usage_line
      expect_invite_line
      expect_errored
    end

    it "1.1)  one strange argument - error / list / invite" do
      invoke 'fiffle'
      expect :styled, /\Aunrecognized action ['"]?fiffle['"]?\z/
      expect :styled, /\Aknown actions are \('?init'?, '?status'?\b/
      expect_invite_line
      expect_errored
    end

    it "1.2)  one strange option-looking argument - error / invite" do
      invoke '-x'
      expect 'invalid option: -x'
      expect_invite_line
      expect_errored
    end

    it "1.4)  one valid option-looking argument (help) - help screen" do
      invoke '-h'
      expect_usage_line
      expect_maybe_a_blank_line
      expect_header_line 'actions'
      expect %r(\A  +-h, --help \[cmd\]  +this screen\.?)
      expect :styled, %r(\A  +init  +init a <workspace>)
      expect %r(\A  +this is the second line)
      expect %r(\A  +status  +get status of a workspace\.?)
      expect_maybe_a_blank_line
      expect :styled, /\Ause '?bzn -h <action>'? for help on that action\.?\b/
      expect_succeeded
    end

    # ~ business

    def expect_usage_line
      expect :styled, 'usage: bzn <action> [..]'
    end

    def expect_invite_line
      expect :styled, /\Ause '?bzn -h'? for help\z/
    end
  end
end
