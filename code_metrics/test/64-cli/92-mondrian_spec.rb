require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] CLI - mondrian" do

    TS_[ self ]

    Home_::Zerk_lib_[].test_support::Non_Interactive_CLI::Fail_Early[ self ]

    me = 'mondrian'

    it "ping" do

      invoke me, '-ping'
      want_on_stderr 'hello from mondrian'
      want_succeed
    end

    it "strange primary - unknown // available" do

      invoke me, '-ziz-wiz'
      want_on_stderr "unknown primary \"-ziz-wiz\""
      want %r(\Aavailable primaries: .*(?<![[:alnum:]])-width\b)
        # the above is currently very long but meh
      _want_failed_commonly
    end

    ambi_N = 4
    it "ambiguous primary - in one line, splays #{ ambi_N } alternatives" do

      invoke me, '-he'
      on_stream :serr
      _rx = %r(\Aambiguous primary "-he" - did you mean (.+)\?\z)
      md = nil
      want_line_by do |line|
        md = _rx.match line
      end
      _want_failed_commonly

      _these = md[1].split %r(,[ ]| or )
      ambi_N == _these.length or fail  # ..
    end

    it "path is required" do

      invoke me

      want_on_stderr %r(\Arequired: -path and\b)

      _want_failed_commonly
    end

    it "money (mocked)" do

      invoke me, '-head-const', 'xx', 'mock-path-1.code'

      _big_string = <<-HERE.unindent
        +------+
        | flim |
        | flam |
        +------+
      HERE

      want_on_stdout_lines_in_big_string _big_string

      want_succeed
    end

    context "numeric option" do

      same = '-width'

      it "argument stream end early - talkin bout expecting" do

        invoke me, same
        want_on_stderr "#{ same } requires an argument"
        _want_failed_commonly
      end

      it "not look like an integer" do

        invoke me, same, '1.0'
        want_on_stderr %(#{ same } does not look like integer: "1.0")
        _want_failed_commonly
      end

      it "not positive nonzero (clever thing with method names)" do

        invoke me, same, '0'
        want_on_stderr "#{ same } must be positive nonzero (had 0)"
        _want_failed_commonly
      end

      it "money" do

        invoke me, same, '313', '-head-const', 'xx', 'mock-path-1.code'

        _big_string = <<-HERE.unindent
          +----------+
          | pretend  |
          | i am 313 |
          | wide     |
          +----------+
        HERE

        want_on_stdout_lines_in_big_string _big_string
        want_succeed
      end
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
      want_each_on_stderr_by do |line|
        p[ line ]
      end

      stack = [
        %r((?<![a-z])-head-const(?!-)),
        %r(\Aprimaries:$),
        %r(\Ausage: ze-pnsa.*(?<![a-z])-path(?!-)),
      ]

      want_succeed

      if stack.length.nonzero?
        fail
      end
    end

    def _want_failed_commonly
      # want "try 'ze-pnsa -h'
        # for now, no invites just to be like `find`
      want_fail
    end

    def subject_CLI
      Home_::Mondrian_[]
    end

    def prepare_subject_CLI_invocation cli
      NOTHING_
    end
  end
end
# #born
