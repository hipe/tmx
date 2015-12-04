require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI canon" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_behavior

    with_invocation  # (root)

    context "  0)  no arguments - error / usage / invite" do

      shared_subject :state_ do
        line_oriented_state_from_invoke  # no args
      end

      it "result in error exitstatus" do
        results_in_error_exitstatus_
      end

      it "line talking bout expecting action" do
        first_line.should match_ expecting_action_line
      end

      it "usage line (for branch)" do
        second_line.should match_ branch_usage_line_
      end

      it "invite line" do
        last_line.should match_ action_invite_line_
      end
    end

    context "1.1)  one strange argument - error / list / invite" do

      shared_subject :state_ do
        line_oriented_state_from_invoke 'fiffle'
      end

      it "result in error exitstatus" do
        results_in_error_exitstatus_
      end

      it "unrec action" do
        first_line.should match_ unrecognized_action :fiffle
      end

      it "known actions are" do
        second_line.should match_ known_actions_are_
      end

      it "invite line" do
        last_line.should match_ action_invite_line_
      end
    end

    context "1.2)  one strange option-looking argument - error / invite" do

      shared_subject :state_ do
        line_oriented_state_from_invoke '-x'
      end

      it "result in error exitstatus" do
        results_in_error_exitstatus_
      end

      it "invalid option (straight from optparse)" do
        first_line.should match_ invalid_option '-x'
      end

      it "invite line" do
        last_line.should match_ action_invite_line_
      end

      it "only these two lines" do
        state_.number_of_lines.should eql 2
      end
    end

    context "1.4)  one valid option-looking argument (help) - help screen" do

      shared_subject :state_ do
        help_screen_oriented_state_from_invoke '-h'
      end

      it "succeeds" do
        results_in_success_exitstatus_
      end

      it "branch usage line" do
        first_line_of_section( 0 ).should match_ branch_usage_line_
      end

      it "branch secondary syntax line" do
        section_child( 0, 0 ).should match_ branch_secondary_syntax_line_
      end

      it "actions (eek!)" do

        on_body_lines_from_help_screen_section_ 'actions'

        expect %r(\A  +-h, --help \[cmd\]  +this screen\.?)

        expected_action_name_string_array_.each do |s|
          send :"expect__#{ s }__item"
        end
      end

      it "branch invite line" do
        only_line_of_section( -1 ).should match_ branch_invite_line_
      end
    end

    memoize :expected_action_name_string_array_ do
      %w(init status workspace collection source)
    end

    def expect__init__item
      expect_item :init, :styled, %r(\binit a <workspace>),
        %r(\bthis is the second line of the init description\b)
    end

    def expect__status__item
      expect_item :status, %r(\bstatus\b.+\bworkspace)
    end

    def expect__workspace__item
      expect_item :workspace, %r(\bmanage workspaces\b)
    end

    def expect__collection__item
      expect_item :collection, %r(\bmanage collections\b)
    end

    def expect__source__item
      expect_item :source, %r(\bmanage sources\b)
    end

    context "2.4x3) help with a good argument" do

      shared_subject :state_ do
        help_screen_oriented_state_from_invoke '-h', 'ini'
      end

      it "succeeds" do
        results_in_success_exitstatus_
      end

      it "usage" do

        on_lines_from_help_screen_section_ 'usage'
        expect :styled, 'usage: xaz init [-d] [-v] <path>'
        expect %r(\A[ ]{7}xaz init -h\z)
        expect_maybe_a_blank_line
      end

      it "description" do

        # (because the lines aren't indented, the tree
        # parse doesn't group these guys together.)

        sta = state_
        d = sta.lookup_index 'description'

        a = []
        cx = sta.tree.children
        3.times do
          a.push cx[ d += 1 ].x
        end

        stdout_stderr_against_emissions a

        expect :styled, 'init a <workspace>'
        expect 'this is the second line of the init description'
        expect_maybe_a_blank_line
      end

      it "options" do

        on_body_lines_from_help_screen_section_ 'options'
        expect %r(\A[ ]{4}-d, --dry-run\z)
        expect %r(\A[ ]{4}-v, --verbose\z)
        expect %r(\A[ ]{4}-h, --help[ ]{10,}this screen\z)
        expect_maybe_a_blank_line
      end

      it "argument" do

        on_body_lines_from_help_screen_section_ 'argument'
        expect %r(\A[ ]{4}<?path?>[ ]{7,}the dir)
      end
    end
  end
end
