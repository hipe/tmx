require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI::Actions

  describe "[br] CLI actions - level-2 - cannon" do

    extend TS_

    with_invocation 'workspace'

    context "(cannon numbers are relativized) (errors)" do

      it "  0) (no args) - error / usage / invite" do
        invoke
        expect_branch_pattern_zero
      end

      it "1.1) (funky arg) error / usage / invite" do
        invoke 'fiffle'
        expect_branch_pattern_one_one
      end

      it "1.2) (funky opt) error / invite" do
        invoke '-x'
        expect_branch_pattern_one_two
      end

      it "1.4) (help screen) (normal style)" do
        invoke '-h'
        expect_helpscreen_for_workspace_node
      end
    end

    context "-" do

      with_invocation

      it "1.4) (help screen) (goofy style)" do
        invoke '-h', 'workspace'
        expect_helpscreen_for_workspace_node
      end
    end

    def expect_helpscreen_for_workspace_node
      expect_help_screen_first_half
      expect_help_screen_second_half
      expect_succeeded
    end

    def expect_usage_line
      expect :styled, 'usage: bzn workspace <action> [..]'
    end

    def expect_secondary_syntax_line
      expect "#{ ' ' * 7 }bzn workspace -h"
    end

    def expect_description_line
      expect :styled, %r(\Adescription: .*\bworkspaces?\b)
    end

    def expect_options
      expect %r(\A[ ]{4,}-h, --help[ ]{10,}this screen\z)i
      expect_maybe_a_blank_line
    end

    def expect_help_screen_second_half
      expect_header_line 'action'
      expect %r(\A[ ]{4,}rm[ ]{10,}removes? a workspace)i
    end

    def expect_invite_line
      expect :styled, /\Ause '?bzn workspace -h'? for help\z/
    end

    self::EXPECTED_ACTION_NAME_S_A = [ 'init', 'status', 'workspace' ].freeze
  end
end
