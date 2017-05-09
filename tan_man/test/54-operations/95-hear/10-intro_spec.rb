require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - hear - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API

# (1/N)
    context "unrecognized input" do

      it "fails" do
        _fails
      end

      it "the first line of the emission explains the problem" do

        _actual = _many_lines_of_emission_expression.fetch 0
        _actual == 'unrecognized input ["zing", "zang"]. known definitions:' || fail
      end

      it "the remaining lines are (for now) numerous.." do

        actual = _many_lines_of_emission_expression
        ( 7..9 ).include? actual.length || fail
        actual.detect { |line| /\bANY_TOKEN\b/ =~ line } || fail
      end

      shared_subject :_many_lines_of_emission_expression do
        black_and_white_lines _tuple.first
      end

      shared_subject :_tuple do

        call_API(
          * the_subject_action_for_hear_,
          :words, %w( zing zang ),  # near `hear_words`
        )

        a = []
        expect :error, :unrecognized_utterance do |ev|
          a.push ev
        end

        a.push execute
        a
      end
    end

    def _fails
      _tuple.last.nil? || fail
    end

    # ==
    # ==
  end
end
