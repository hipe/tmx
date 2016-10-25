require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - the punchlist report (integrates almost everything so far)" do

    TS_[ self ]
    use :CLI
    use :non_interactive_CLI_fail_early

    context "(context)" do

      it "list them" do
        invoke _subject_operation
        expect_on_stdout "punchlist"
        expect_succeeded
      end

      it "bad name" do
        invoke _subject_operation, 'floofie'
        expect_on_stderr "unrecognized report: \"floofie\""
        expect_on_stderr "available reports: (punchlist)"
        expect_failed_normally_
      end

      it "wee CURRENTLY STUBBED AT OPERATION" do
        invoke 'reports', 'punchlist'
        expect_on_stdout_lines_in_big_string __this_big_string
        expect_succeeded
      end

      given_ %w( gilius adder stern dora )  # weird order

      def __this_big_string

        <<-HERE.unindent
          # first three
          adder

          # second group
          dora
          gilius

          # third three
          stern
        HERE
      end
    end

    map = 'reports'
    define_method :_subject_operation do
      map
    end
  end
end
