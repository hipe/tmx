require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - the punchlist report (integrates almost everything so far)" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI
    use :non_interactive_CLI_fail_early

    context "(counts)" do

      it "the whole thing (KNOWN ISSUES)" do

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

      memoize :_subject_operation do
        %w( test-all -counts )
      end
    end
  end
end
