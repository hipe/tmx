require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI

  describe "[br] CLI canon" do

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

      self.class::EXPECTED_ACTION_NAME_S_A.each do |s|
        send :"expect_#{ s }_item"
      end

      expect_maybe_a_blank_line

      expect_branch_invite_line
      expect_succeeded
    end

    def expect_init_item
      expect_item :init, :styled, %r(\binit a <workspace>),
        %r(\bthis is the second line of the init description\b)
    end

    def expect_status_item
      expect_item :status, %r(\bstatus\b.+\bworkspace)
    end

    def expect_workspace_item
      expect_item :workspace, %r(\bmanage workspaces\b)
    end

    def expect_collection_item
      expect_item :collection, %r(\bmanage collections\b)
    end

    def expect_source_item
      expect_item :source, %r(\bmanage sources\b)
    end

    it "2.4x3) help with a good argument" do
      invoke '-h', 'ini'
      expect_help_screen_for_init
    end

    self::EXPECTED_ACTION_NAME_S_A = [ 'init', 'status', 'workspace', 'collection', 'source' ].freeze
  end
end
