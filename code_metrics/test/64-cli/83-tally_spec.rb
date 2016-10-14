require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] CLI - tally" do

    TS_[ self ]
    use :CLI_expectations

    context "in toplevel helpscreen, the entry for this action.." do

      it "exists" do
        _subject
      end

      it "properties render correctly in the summary [#br-002]:A " do

        act = _subject.to_column_B_string :unstyled

        exp = <<-HERE.unindent
          find every occurrence of every <word> in every file
          selected by every <path> recursively and hackishly..
        HERE

        # for now, we've got to normalize these both because
        # of some nasty #flickering behavior (see #gotcha [#012]):

        exp.chomp!

        act.chomp!
        act.chomp!  # only when run alone is this necessary (at writing)

        act.should eql exp
      end

      me = 'tally'
      define_method :_subject do
        toplevel_helpscreen_actions_.fetch me
      end
    end

    # -- etc

    def invocation_strings_for_expect_stdout_stderr
      memoized_invocation_strings_for_expect_stdout_stderr_
    end

    def get_invocation_strings_for_expect_stdout_stderr
      get_invocation_strings_for_expect_stdout_stderr_
    end
  end
end
