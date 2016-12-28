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

    it "help" do

      invoke me, '-help'

      monadic_emptiness = -> _ do  # MONADIC_EMPTINESS_
        NOTHING_
      end

      stack = nil
      p = -> line do
        if stack.last =~ line
          stack.pop
          if stack.length.zero?
            p = monadic_emptiness
          end
        end
        NIL
      end
      expect_each_on_stderr_by do |line|
        p[ line ]
      end

      stack = [
        %r((?<![a-z])-head-const(?!-)),
        %r(\Aprimaries:$),
        %r(\Ausage: ze-pnsa.*(?<![a-z])-head-path(?!-)),
      ]

      expect_succeeded

      if stack.length.nonzero?
        fail
      end
    end

    def subject_CLI
      Home_::Mondrian_[]
    end

    def prepare_CLI cli
      NOTHING_
    end
  end
end
# #born
