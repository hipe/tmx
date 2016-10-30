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

          invoke_it

          _surveyor = TS_::CLI::LineSurveyor.new do |o|

            o.one_line_must_look_like_this = -> do
              find_this = ::File.basename __FILE__
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

          survey = _surveyor.to_survey

          expect_each_on_stdout_by :puts do |line|
            survey.see_line line
          end

          expect_succeeded

          survey.finish
        end
      end

      context "provide neither named directories nor map modifiers" do

        given do
          _invoke
        end

        it "you get the whole stream from `map`", wip: true do
          TS_._K
        end
      end

      context "provide `map` modifiers only" do

        given do
          _invoke '-order', 'after'
        end

        it "you get the modified stream from `map`", wip: true do
          TS_._K
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

    memoize :_top_token do
      'test-all'
    end
  end
end
