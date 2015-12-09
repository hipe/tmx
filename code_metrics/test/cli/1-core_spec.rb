require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] CLI" do

    TS_[ self ]
    use :CLI
    use :CLI_support_expectations

    it "0.0 - nothing" do

      invoke

      expect_expecting_action_line
      expect_usaged_and_invited
    end

    it "1.4 - help at level 0" do

      invoke '-h'

      exp = flush_to_expect_stdout_stderr_emission_summary_expecter

      exp.expect_chunk 14, :e
      exp.expect_no_more_chunks
    end

    it "2.4 - help at level 1" do

      invoke 'line-count', '-h'

      exp = flush_to_expect_stdout_stderr_emission_summary_expecter
      exp.expect_chunk 24, :e
      exp.expect_no_more_chunks
    end
  end
end
