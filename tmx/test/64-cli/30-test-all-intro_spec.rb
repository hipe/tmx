require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - the punchlist report (integrates almost everything so far)" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_fail_early
    use :CLI

    context "(counts)" do

      it "the whole thing (KNOWN ISSUES)" do
        # (move to a dedicated file about counts whenever)

        dir = ::File.dirname __FILE__
        dir2 = ::File.join ::File.dirname( dir ), '54-operations'
        ::Dir.exist? dir2 || fail

        same = '-test-directory'
        invoke( * _subject_operation, same, dir2, same, dir, '-verbose' )  # (exactly one v is necessary)

        expect_on_stdout %r(\A[ ]+Test directory[ ][ ]Number of test files[ ]{3,}\z)

        same = %r(\A[ ]*[^ ]+[ ]{2,}\d+[ ][ ][-*]+\z)
        expect same
        expect same

        expect_succeeded
      end

      def __this_big_string

        # NOTE hard-coded for now only because whatsitcalled is long

        <<-HERE.unindent
          foo
          bar
        HERE
      end

      def _subject_operation
        [ _top_token, '-counts' ]
      end

      def prepare_CLI cli
        _prepare_CLI_as_real cli
      end
    end

    context "intro to the glue that glues together the centralest things [#006]" do

      context "strange primary" do

        given do
          _invoke '-strange'
        end

        it "gives you a compounded ~\"did you mean..\"" do
          _seen
        end

        it "has help (and some others)" do
          h = _seen
          h[ '-help' ] || fail
          h[ '-verbose' ] || fail
          h[ '-slice' ] || fail
          h[ '-order' ] || fail
          h[ '-test-directory' ] || fail
          h[ '-page-by' ] || fail
        end

        shared_subject :_seen do

          invoke_it

          expect_on_stderr 'unknown primary: "-strange"'

          md = nil
          expect_line_by do |line|
            md = %r(\Aexpecting \{ ([^\}]+) \}\z).match line
          end

          expect_failed_normally_

          seen = {}
          md[1].split(' | ').each { |s| seen[s] = true }
          seen
        end

        def prepare_CLI cli
          cli.test_file_name_pattern_by { TS_._NEVER_USED }
          cli.test_directory_entry_name_by { TS_._NEVER_USED }
        end
      end

      context "name directories explicitly only" do

        given do
          _invoke '-test-directory', ::File.dirname( __FILE__ )
        end

        it "succeeds (zero exitstatus)" do
          _line_survey || fail
        end

        it "finds a reaonsable number of files" do

          _count = _line_survey.total_line_count
          _count == 6 or fail "expected six test files had #{ _count } (was a test file added?)"  # be jerks at first
        end

        it "all other output lines look like SOME test file" do
          _line_survey.strange_lines && fail
        end

        it "eventually, this selfsame file showed up somewhere in the list" do
          _line_survey.did_find || fail
        end

        shared_subject :_line_survey do
          _line_survey_for __FILE__
        end

        def prepare_CLI cli
          _prepare_CLI_as_real cli
        end
      end

      context "provide neither named directories nor map modifiers" do

        given do
          _invoke
        end

        it "you get the whole stream from `map`" do

          _expect_the_number_identifiers_of_the_test_files_to_be_in_this_order 9, 10, 1
        end

        def prepare_CLI cli
          _prepare_CLI_for_hacked_universe cli, %w( tyris trix )
        end
      end

      context "provide map modifiers only" do

        given do
          _invoke '-order', 'cost'
        end

        it "you get the modified stream from `map`" do

          _expect_the_number_identifiers_of_the_test_files_to_be_in_this_order 1, 9, 10
        end

        def prepare_CLI cli
          _prepare_CLI_for_hacked_universe cli, %w( tyris trix )
        end
      end

      context "the crazy case - when you pass a path that leads to noent" do

        given do

          _noent = ::File.join ::Skylab::TestSupport::Fixtures.directory( :not_here ), 'fugazi', 'torst'
          _invoke '-order', 'cost', '-test-directory', _noent
        end

        it "says noent (new in this edition - no raising exception)" do

          invoke_it
          expect_on_stderr %r(\ANo such file or directory - .+\bfugazi\b)
          expect "(no results.)"
        end
      end

      context "the crazy case when money" do

        given do

          _json_file = TS_::Operations::Map::Dir01[ 'tyris' ]
          _test_dir = ::File.expand_path ::File.join( '..', 'torsts' ), _json_file
          _invoke '-order', 'cost', '-test-directory', _test_dir
        end

        it "cache money" do

          _expect_the_number_identifiers_of_the_test_files_to_be_in_this_order 9, 10
        end

        def prepare_CLI cli

          _prepare_CLI_for_hacked_universe cli

          cli.metadata_filename_by { 'this.json' }
        end
      end

      def _invoke * plus
        plus[0,0] = _subject_operation
        will_invoke_via_argv plus
      end

      shared_subject :_subject_operation do
        [ _top_token, '-list-files' ]
      end
    end

    def _expect_the_number_identifiers_of_the_test_files_to_be_in_this_order * d_a

      invoke_it

      rx = _d_speg_rx

      scn = Common_::Polymorphic_Stream.via_array d_a

      expect_each_on_stdout_by do |line|

        _md = rx.match line
        _actual_d = _md[0].to_i

        _expected_d = scn.gets_one
        _actual_d == _expected_d || fail

        NOTHING_  # keep parsing
      end

      expect_succeeded

      scn.no_unparsed_exists || fail
    end

    def _line_survey_for test_file

      invoke_it

      survey = __surveyor_for( test_file ).to_survey

      expect_each_on_stdout_by :puts do |line|
        survey.see_line line
      end

      expect_succeeded

      survey.finish
    end

    def __surveyor_for test_file

      TS_::CLI::LineSurveyor.new do |o|

        o.one_line_must_look_like_this = -> do
          find_this = ::File.basename test_file
          -> line do
            find_this == ::File.basename( line )
          end
        end.call

        o.every_other_line_must_look_like_this = -> do
          pattern = TestSupport_::Init.test_file_name_pattern
          -> line do
            ::File.fnmatch pattern, line
          end
        end.call
      end
    end

    define_method :_prepare_CLI_for_hacked_universe, ( -> do

      glob = '*-speg.kd'
      test_dir = 'torsts'

      -> cli, s_a=nil do

        if s_a
          cli.json_file_stream_by do
            TS_::Operations::Map::Dir01::JSON_file_stream_via[ s_a ]
          end
        end

        cli.test_directory_entry_name_by do
          test_dir
        end

        cli.test_file_name_pattern_by do
          glob
        end
        NIL
      end
    end.call )

    def _prepare_CLI_as_real cli

      o = TestSupport_::Init

      tden = o.test_directory_entry_name
      cli.test_directory_entry_name_by { tden }

      tfnp = o.test_file_name_pattern
      cli.test_file_name_pattern_by { tfnp }
    end

    memoize :_d_speg_rx do
      /\d+(?=-speg\.kd\z)/
    end

    memoize :_top_token do
      'test-all'
    end
  end
end
