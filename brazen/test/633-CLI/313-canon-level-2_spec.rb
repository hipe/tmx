require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - canon level-2" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_behavior

    with_invocation 'workspace'

    context "(canon numbers are relativized)" do

      it "  0) (no args) - error / usage / invite" do

        invoke
        want_branch_expression_pattern_zero__
      end

      it "1.1) (funky arg) error / usage / invite" do

        invoke 'fiffle'
        want_branch_expression_pattern_one_dot_one__
      end

      it "1.2) (funky opt) error / invite" do

        invoke '-x'
        want_branch_expression_pattern_one_dot_two__
      end
    end

    context "1.4) (help screen) (normal style)" do

      shared_subject :state_ do
        invoke '-h'
        flush_invocation_to_help_screen_oriented_state
      end

      it "succeeds" do
        results_in_success_exitstatus_
      end

      it "usage" do
        _usage
      end

      it "desc" do
        _desc
      end

      it "actions" do
        _actions
      end

      it "invite" do
        _invite
      end
    end

    context "1.4) (help screen) (goofy style)" do

      shared_subject :state_ do

        using_want_stdout_stderr_invoke_via(
          :mutable_argv, [ '-h', 'workspace' ],
          :prefix, nil,
        )

        flush_invocation_to_help_screen_oriented_state
      end

      it "succeeds" do
        results_in_success_exitstatus_
      end

      it "usage" do
        _usage
      end

      it "desc" do
        _desc
      end

      it "actions" do
        _actions
      end

      it "invite" do
        _invite
      end
    end

    def _usage

      on_lines_from_help_screen_section_ 'usage'
      want_branch_usage_line_
      want_stdout_stderr_via branch_secondary_syntax_line_
      want_a_blank_line
    end

    def _desc

      on_lines_from_help_screen_section_ 'description'
      want :styled, %r(\Adescription: .*\bworkspaces?\b)
      want_no_more_lines
    end

    def _actions

      on_body_lines_from_help_screen_section_ 'actions'
      want %r(\A[ ]{4,}-h, --help \[cmd\][ ]{10,}this screen \(or)
      want %r(\A[ ]{4,}ping\z)
      want %r(\A[ ]{4,}rm[ ]{10,}removes? a workspace)
      want %r(\A[ ]{4,}summarize\z)
      want_a_blank_line
    end

    def _invite
      expect( only_line_of_section( -1 ) ).to match_ branch_invite_line_
    end

    memoize :expected_action_name_string_array_ do
      %w( ping rm summarize )
    end
  end
end
