require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tmx] CLI - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_non_interactive_CLI_fail_early
    use :CLI

    context "interactive and no args" do

      given do
        yes_interactive
        argv
      end

      it "whine and usage and invite" do
        _expect_expecting_STDIN_etc
      end
    end

    context "interactive and has some args and strange arg" do

      given do
        yes_interactive
        argv '--zoopie', '-h', '--foipie'
      end

      it "whine about opts" do
        _expect_unknown_option_zoopie_etc
      end
    end

    context "interactive and some arguments and parses ok" do

      given do
        yes_interactive
        argv '-w', '40'
      end

      it "whine about expecting stdin" do
        _expect_expecting_STDIN_etc
      end
    end

    context "non-interactive and arguments and fail on arguments" do

      given do
        non_interactive
        argv '--zoopie'
      end

      it "whine" do
        _expect_unknown_option_zoopie_etc
      end
    end

    context "interactive mode and help and something else" do

      given do
        yes_interactive
        argv '-h', '--bazonga'
      end

      it "displays help and exits" do
        _expect_help_etc
      end
    end

    context "non-interactive and arguments and help" do

      given do
        non_interactive
        argv '-w', '20', '-h'
      end

      it "displays help and exits (even though non-interactive)" do
        _expect_help_etc
      end
    end

    context "non-interactive no options no input" do

      given do
        non_interactive
        argv
      end

      it "gently mentions it but does not fail" do
        _expect_no_lines_in_input
      end
    end

    context "non-interactive yes options no input" do

      given do
        non_interactive
        argv '-w', '40'
      end

      it "gently mentions it but does not fail" do
        _expect_no_lines_in_input
      end
    end

    context "non-interactive yes options yes input" do

      given do
        non_interactive do |y|
          y << "jumanny-fumanny-1 32"
          y << "an-other-alternative 16"
        end
        argv '-w', '40'
      end

      it "looks good" do

                          #one456789ten3456789twenty6789thirty6789f
        expect_on_stdout  "jumanny-fumanny-1     32  ++++++++++++++"
        expect_on_stdout  "an-other-alternative  16  +++++++       "

        # (summaries later, probably as an option.)
        expect_succeed
      end
    end

    def _expect_help_etc

      expect_usage_line_
      expect_empty_puts

      expect %r(\Asynopsis: [a-z])i
      expect_empty_puts

      expect 'options:'

      spy = _once_asserter.once
      p = spy.proc

      expect_each_by do |line|
        p[ line ]
        NOTHING_
      end

      expect_succeed

      spy.close
    end

    def _expect_no_lines_in_input
      expect_on_stderr '(no lines in input. done.)'
      expect_succeed
    end

    def _expect_unknown_option_zoopie_etc
      expect_on_stderr %r(\Aunknown primary "--zoopie\"\z)
      expect_on_stderr %r(\Aexpecting \{)
      expect_invite_etc_
    end

    def _expect_expecting_STDIN_etc
      expect_on_stderr "expecting STDIN"
      expect_invite_etc_
    end

    shared_subject :_once_asserter do

      _lib = Home_::Zerk_lib_[].test_support
      _lib = _lib::Non_Interactive_CLI::HelpScreenSimplePool

      _lib.define do |o|
        o.mandatory_pool(
          :width,
          :page_size,
          :left_separator, :inner_separator, :right_separator,
        )
      end
    end
  end
end
# #tombstone: full reconception from ancient [as]
