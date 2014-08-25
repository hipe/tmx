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
      expect_branch_usage_line
      expect_branch_auxiliary_usage_line
      expect_maybe_a_blank_line

      expect_header_line 'actions'

      expect %r(\A  +-h, --help \[cmd\]  +this screen\.?)
      expect_item :datastore, %r(\bmanage datastores\b)
      expect_item :init, :styled, %r(\binit a <workspace>),
        %r(\bthis is the second line of the init description\b)
      expect_item :status, %r(\bstatus\b.+\bworkspace)
      expect_item :workspace, %r(\bmanage workspaces\b)
      expect_maybe_a_blank_line

      expect_branch_invite_line
      expect_succeeded
    end

    it "2.4x3) help with a good argument" do
      invoke '-h', 'ini'
      expect_help_screen_for_init
    end

    self::EXPECTED_ACTION_NAME_S_A = [ 'datastore', 'init', 'status', 'workspace' ].freeze
  end
end
