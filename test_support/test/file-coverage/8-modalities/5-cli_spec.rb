require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] file-coverage - modalities - CLI", wip: true do

    TS_[ self ]
    use :file_coverage
    use :file_coverage_expect_stdin_stdout

    it "2.2 - help infixed - ambiguity!" do

      _invoke '-h', 'fi'

      expect "ambiguous action \"fi\" - did you mean \"file-coverage\" or \"files\"?"
      _expect_generic_invite
      expect_failed
    end

    _ACTION = 'file-c'

    it "2.2 - help infixed - 1) usage 2) desc 3) opts" do

      _invoke '-h', _ACTION

      s = flush_to_string_contiguous_lines_on_stream :e
      expect_succeeded

      s.should be_include(
        "the test file suffixes to use (default: \"_spec.rb\")" )
    end

    it "minimal" do

      _invoke _ACTION, '_speg.rb', _path( :one )

      on_stream :o
      expect :styled, "└──( foo.rb <-> foo_speg.rb )"
      expect_succeeded
    end

    def _invoke * argv
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    def subject_CLI
      Home_::CLI
    end

    _PROG_NAME = '-s-t-'

    define_method :invocation_strings_for_expect_stdout_stderr, -> do
      a = [ _PROG_NAME ].freeze
      -> do
        a
      end
    end.call

    def _path sym, s=nil

      head = fixture_tree_test_dir_for_ sym
      if s
        ::File.join head, s
      else
        head
      end
    end

    def _expect_generic_invite

      expect "use '#{ _prog_name } -h' for help"
    end

    define_method :_prog_name do
      _PROG_NAME
    end

    def result_for_failure_for_expect_stdout_stderr

      Home_::CLI_support_[]::GENERIC_ERROR_EXITSTATUS
    end
  end
end

# :+#tombstone: this used to be home to [#ts-010] "dark hack"
