require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - mount one-offs" do

    TS_[ self ]

    use :memoizer_methods
    use :non_interactive_CLI_fail_early
    use :CLI

    it "get help of a mounted one-off (the hard way) (live)" do
      invoke '--help', 'snap'
      _expect_this_same_help_screen
    end

    it "get help of a mounted one-off (the easy way) (live)" do
      invoke 'snap', '--help'
      _expect_this_same_help_screen
    end

    it "no arg" do
      invoke 'snap'
      expect_on_stderr %r(\bexpecting\b)
      expect %r(\Ausage: tmz snap\b)
      expect_fail
    end

    it "ambiguous between two categories of operator:" do
      invoke 'p'
      on_stream :serr
      md = nil
      expect_line_by do |line|
        md = %r(\Aambiguous primary \"p\" - did you mean (?<list>.+)\?\z).match line
        md || fail
      end
      expect_failed_normally_
      these = md[ :list ].split %r(, | or )
      'ping' == these.first || fail
      # (assume there are no sidesystems mounted (but there might be 3 here))
      'partition' == these.last || fail
    end

    # for coverage of fuzzy vis-a-vis mounteds (with each other),
    # we are #borrowing-coverage from [#gi-015.1]<->:[#022.2]
    # (but really, if the above test of ours works then this is likely OK too.)

    it "ping" do
      invoke 'snap', '--ping'
      expect_on_stderr 'hello from tmz snap!'
      expect_succeed
    end

    def _expect_this_same_help_screen

      a = [] ; line = nil

      a.push -> do
        %r(\Adescription: ) =~ line || fail
      end
      a.push -> do
        line && fail  # depends on client
      end
      a.push -> do
        %r(\Ausage: tmz snap \{ ) =~ line || fail
      end
      p = -> do
        expect = a.pop
        if expect
          expect[]
        else
          p = -> do
            NIL  # for KEEP_PARSING_
          end
        end
        NIL  # for KEEP_PARSING_
      end
      expect_each_on_stderr_by do |line_|
        line = line_
        p[]
      end
      expect_succeed
    end

    def prepare_subject_CLI_invocation cli
      # (see other)
      NOTHING_
    end
  end
end
