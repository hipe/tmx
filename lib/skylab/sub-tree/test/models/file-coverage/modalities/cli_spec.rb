require_relative '../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  describe "[st] models - file-coverage - modalities - CLI" do

    extend TS_

    use :expect_stdin_stdout

    it "2.2 - help infixed - ambiguity!" do

      _invoke '-h', 'fi'

      expect "ambiguous action \"fi\" - did you mean \"file-coverage\" or \"files\"?"
      _expect_generic_invite
      expect_failed
    end

    _ACTION = 'file-c'

    it "2.2 - help infixed - 1) usage 2) desc 3) opts" do

      _invoke '-h', _ACTION

      s = get_string_for_contiguous_lines_on_stream :e
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

      if s
        ::File.join Fixture_tree_[ sym ], s
      else
        Fixture_tree_[ sym ]
      end
    end

    def _expect_generic_invite

      expect "use '#{ _prog_name } -h' for help"
    end

    define_method :_prog_name do
      _PROG_NAME
    end

    def result_for_failure_for_expect_stdout_stderr

      Home_.lib_.brazen::CLI::GENERIC_ERROR_
    end
  end
end

# :+#tombstone: this used to be home to [#ts-010] "dark hack"
