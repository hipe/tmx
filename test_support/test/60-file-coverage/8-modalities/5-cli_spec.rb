require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] file-coverage - modalities - CLI" do

    TS_[ self ]
    use :memoizer_methods
    use :file_coverage
    use :file_coverage_want_stdin_stdout

    _ACTION = 'file-c'

    context "help screen (infixed)" do

      it "usage" do
        _s = _section( :usage ).first_line.unstyled_styled
        _s =~ /\Ausage: fczzy file-coverage \[.+\] <path>$/ || fail
      end

      it "description" do
        _sect = _section :description
        _hi = _sect.raw_line( -2 )
        _hi.string =~ /\bapplication files\b.+\bappear as red\b/ || fail
      end

      it "options" do
        sect = _section :options
        ( 3..5 ).include? sect.line_count or fail
        _ = sect.raw_line( -2 ).string
        _exp = "the test file suffixes to use (default: \"_spec.rb\")"
        _.include?( _exp ) || fail
      end

      it "argument" do
        _sect = _section :argument
        _sect.raw_line( -1 ).string.include?( "the path" ) || fail
      end

      def _section sym
        __coarse_parse.section sym
      end

      shared_subject :__coarse_parse do
        _invoke '-h', _ACTION
        _line_o_a = release_lines_for_want_stdout_stderr
        Zerk_test_support_[]::CLI::Want_Section_Coarse_Parse.
          via_line_object_array _line_o_a
      end
    end

    it "minimal" do

      _path = fixture_tree :one
      _invoke _ACTION, '--test-file-suffi', '_speg.kode', _path

      on_stream :o
      want :styled, "└──( foo.kode <-> foo_speg.kode )"
      want_succeed
    end

    def _invoke * argv
      using_want_stdout_stderr_invoke_via_argv argv
    end

    def _path sym, s=nil

      head = fixture_tree_test_dir_for_ sym
      if s
        ::File.join head, s
      else
        head
      end
    end

    def _want_generic_invite

      want "use '#{ _prog_name } -h' for help"
    end

    def result_for_failure_for_want_stdout_stderr

      Home_::CLI_support_[]::GENERIC_ERROR_EXITSTATUS
    end

    def build_invocation_for_want_stdout_stderr argv, sin, sout, serr, pn_s_a

      Home_::CLI.new argv, sin, sout, serr, pn_s_a do |o|

        o.filesystem_by do
          Home_.lib_.system.filesystem
        end
      end
    end

    _PN_S_A = %w(fczzy)

    define_method :_prog_name do
      _PN_S_A.fetch 0
    end

    define_method :invocation_strings_for_want_stdout_stderr do
      _PN_S_A
    end
  end
end
# #tombstone: ambiguity test
# :+#tombstone: this used to be home to [#ts-010] "dark hack"
