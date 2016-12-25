require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] CLI - mondrian" do

    TS_[ self ]

    Home_::Zerk_lib_[].test_support::Non_Interactive_CLI::Fail_Early[ self ]

    me = 'mondrian'

    it "hi." do

      invoke me, '-ping'

      expect_on_stderr 'hello from mondrian'

      expect_succeeded
    end

    it "path is required" do

      invoke me

      expect_on_stderr %r(\Afor now, required: -path and\b)

      expect_failed
    end

    it "money (mocked)" do

      invoke me, '-head-const', 'xx', 'mock-path-1.code'

      _big_string = <<-HERE.unindent
        +------+
        | flim |
        | flam |
        +------+
      HERE

      expect_on_stdout_lines_in_big_string _big_string

      expect_succeeded
    end

    def subject_CLI
      Home_::Mondrian_[]
    end

    def prepare_CLI cli
      NIL  # NOTHING_
    end
  end
end
# #born
