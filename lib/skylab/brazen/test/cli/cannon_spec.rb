require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI

  describe "[br] CLI cannon" do

    extend TS_

    it "  0)  no arguments - error / usage / invite" do
      invoke
      expect_branch_pattern_zero
    end

    it "1.1)  one strange argument - error / list / invite" do
      invoke 'fiffle'
      expect_branch_pattern_one_one
    end

    it "1.2)  one strange option-looking argument - error / invite" do
      invoke '-x'
      expect_branch_pattern_one_two
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
      expect %r(\A  +workspace  +manage workspaces)
      expect_maybe_a_blank_line
      expect :styled, /\Ause '?bzn -h <action>'? for help on that action\.?\b/
      expect_succeeded
    end

    it "2.4x3) help with a good argument" do
      invoke '-h', 'ini'
      expect_help_screen_for_init
    end

    # ~ business

    def expect_usage_line
      expect :styled, 'usage: bzn <action> [..]'
    end

    def expect_invite_line
      expect :styled, /\Ause '?bzn -h'? for help\z/
    end

    self::EXPECTED_ACTION_NAME_S_A = [ 'init', 'status', 'workspace' ].freeze
  end
end
