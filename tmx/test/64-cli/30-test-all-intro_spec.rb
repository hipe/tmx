require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - the punchlist report (integrates almost everything so far)" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI
    use :non_interactive_CLI_fail_early

    context "(counts)" do

      it "the whole thing (KNOWN ISSUES)" do
        # (move to a dedicated file about counts whenever)

        dir = ::File.dirname __FILE__
        dir2 = ::File.join ::File.dirname( dir ), '54-operations'
        ::Dir.exist? dir2 || fail

        same = '-test-directory'
        invoke( * _subject_operation, same, dir2, same, dir )

        expect_on_stdout :<<, %r(\A\| +Test directory \| Number of test files \|  \|\n\z)  # KNOWN ISSUE

        same = %r(\A\| +[^ ]+ \| +\d+ \| [*-]+ \|\n\z)
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
          invoke_it
          expect_on_stderr 'unknown primary: "-strange"'
          expect "expecting { -order | -test-directory }"
          expect_failed_normally_
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
          ( 4 .. 4 ).include? _line_survey.total_line_count or fail  # be jerks at first
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
          _prepare_CLI_for_hacked_universe_with cli, %w( tyris trix )  # revere alpha
        end
      end

      context "provide `map` modifiers only" do

        given do
          _invoke '-order', 'cost'
        end

        it "you get the modified stream from `map`" do

          _expect_the_number_identifiers_of_the_test_files_to_be_in_this_order 1, 9, 10
        end

        def prepare_CLI cli
          _prepare_CLI_for_hacked_universe_with cli, %w( tyris trix )  # same as above
        end
      end

      context "this is the crazy thing (needs new code) - when you have both"

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

    def _prepare_CLI_for_hacked_universe_with cli, s_a

      cli.json_file_stream_by do
        TS_::Operations::Map::Dir01::JSON_file_stream_via[ s_a ]
      end

      cli.test_directory_entry_name_by do
        'torsts'
      end

      cli.test_file_name_pattern_by do
        '*-speg.kd'
      end
    end

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
