require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] CLI - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_expectations
    use :CLI

    it "0.0 - nothing" do

      invoke
      want_expecting_action_line
      want_usaged_and_invited
    end

    context "1.4 - help at level 0" do

      def state_
        toplevel_help_screen_
      end

      it "succeeds" do
        expect( state_.exitstatus ).to match_successful_exitstatus
      end

      it "usage section" do
        state_.lookup 'usage'  # else fails
      end

      context "actions section" do

        it "expect dirs" do
          _expect 'dirs'
        end

        it "expect ext" do
          _expect 'ext'
        end

        it "expect line-count" do
          _expect 'line-count'
        end

        def _expect s

          _bx = toplevel_helpscreen_actions_
          _bx[ s ] or fail "section \"#{ s }\" not found"
        end
      end

      it "invite line" do

        _ = state_.tree.children.last.x.unstyled_content
        expect( _ ).to eql  "use '[CoMe] -h <action>' for help on that action."
      end
    end

    it "2.4 - help at level 1" do

      invoke 'line-count', '-h'

      exp = flush_to_want_stdout_stderr_emission_summary_expecter
      exp.want_chunk 24, :e
      exp.want_no_more_chunks
    end
  end
end
