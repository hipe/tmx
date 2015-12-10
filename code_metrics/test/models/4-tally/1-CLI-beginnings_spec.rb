require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] tally - 1: CLI beginnings" do

    TS_[ self ]
    use :CLI_support_expectations

    context "in toplevel helpscreen, the entry for this action.." do

      it "exists" do
        _subject
      end

      it "properties render correctly in the summary [#br-002]:A " do

        _act = _subject.to_column_B_string :unstyled

        _exp = <<-HERE.unindent
          find every occurrence of every <word> in every file
          selected by every <path> recursively and hackishly..

        HERE

        _act.should eql _exp
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
