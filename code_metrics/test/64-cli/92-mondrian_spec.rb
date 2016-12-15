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

      expect_on_stderr "missing required parameter: -path"

      expect_failed
    end

    it "money (mocked)" do

      invoke me, 'some-path.code'

      _big_string = <<-HERE.unindent
        +------+
        | flim |
        | flam |
        +------+
      HERE

      expect_on_stdout_lines_in_big_string _big_string

      expect_succeeded
    end

    def prepare_CLI cli
      NIL
    end
  end
end
# #born
