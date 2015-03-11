require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI::Actions

  describe "[br] CLI actions - level-2 - canon" do

    extend TS_

    with_invocation 'workspace'

    context "(canon numbers are relativized)" do

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

      it "1.4) (help screen) (goofy style)" do
        using_expect_stdout_stderr_invoke_with_no_prefix '-h', 'workspace'
        expect_helpscreen_for_workspace_node
      end
    end

    def expect_helpscreen_for_workspace_node
      expect_branch_help_screen_first_half
      expect_branch_help_screen_second_half
    end

    def expect_description_line
      expect :styled, %r(\Adescription: .*\bworkspaces?\b)
    end

    def expect_these_actions
      expect %r(\A[ ]{4,}-h, --help \[cmd\][ ]{10,}this screen \(or)
      expect %r(\A[ ]{4,}ping\z)
      expect %r(\A[ ]{4,}rm[ ]{10,}removes? a workspace)
      expect %r(\A[ ]{4,}summarize\z)
    end

    def expect_options
      expect_maybe_a_blank_line
    end

    def expect_help_screen_second_half
      expect_header_line 'action'
      expect %r(\A[ ]{4,}rm[ ]{10,}removes? a workspace)i
    end

    self::EXPECTED_ACTION_NAME_S_A = [ 'ping', 'rm', 'summarize' ].freeze
  end
end
