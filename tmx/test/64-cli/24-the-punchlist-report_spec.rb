require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - the punchlist report (integrates almost everything so far)" do

    TS_[ self ]
    use :non_interactive_CLI_fail_early
    use :CLI

    context "(context)" do

      it "strange primary - whines" do
        invoke _subject_operation, '-strange'
        want_on_stderr "unknown primary \"-strange\""
        want_on_stderr %r(\Aexpecting \{ -[a-z])
        want_failed_normally_
      end

      it "list because no args" do
        invoke _subject_operation
        _want_same_list
      end

      it "list because list primary" do
        invoke _subject_operation, '-list'
        _want_same_list
      end

      def _want_same_list
        want_on_stdout "punchlist"
        want_succeed
      end

      it "bad name" do
        invoke _subject_operation, 'floofie-doofie'
        want_on_stderr "unknown report: \"floofie-doofie\""
        want_on_stderr "available reports: punchlist"
        want_fail
      end

      it "generate it against a small set of four fixture" do
        invoke _subject_operation, 'punchlist'
        want_on_stdout_lines_in_big_string __this_big_string
        want_succeed
      end

      it "reverse" do
        invoke _subject_operation, 'punchlist', '-reverse'
        want_on_stdout_lines_in_big_string __this_reversed_big_string
        want_succeed
      end

      given_test_directories %w( gilius adder stern dora )  # weird order

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

      def __this_reversed_big_string

        <<-HERE.unindent
          # third three
          stern

          # second group
          gilius
          dora

          # first three
          adder
        HERE
      end
    end

    map = 'reports'
    define_method :_subject_operation do
      map
    end
  end
end
