require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - argument scanner" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early

    it "loads." do
      _subject_module
    end

    context "if the first term is not a symbol.." do

      it "fails" do
        _message_lines
      end

      it "says unknown primary **as string (as received)**" do
        _message_lines.first == 'unknown primary: "x"' || fail
      end

      it "offers the alternatives" do
        _message_lines.last == "expecting :x or :y" || fail
      end

      shared_subject :_message_lines do

        _as = __build_argument_scanner "x"

        call_by do
          _as.match_head_against_primaries_hash x: :_no_see_, y: :_no_see_
        end

        y = nil
        expect :error, :expression, :parse_error, :expected_symbol do |y_|
          y = y_
        end

        expect_result UNABLE_
        y
      end
    end

    it "parse a primary against a hash" do

      _as = _build_argument_scanner_without_listener :x, :_no_see_

      _xx = _as.match_head_against_primaries_hash x: :_money_

      _xx == :_money_ || fail
    end

    it "parse that value" do

      as = _build_argument_scanner_without_listener :x, :_money_two_

      _k = as.match_head_against_primaries_hash x: :_money_one_
      _k == :_money_one_ || fail  # redundant with previous test

      as.advance_one

      _kn = as.parse_primary_value
      _xx = _kn.value_x
      _xx == :_money_two_ || fail
    end

    def __build_argument_scanner * x_a

      _l = expect_emission_fail_early_listener
      _subject_module.via_array x_a, & _l
    end

    def _build_argument_scanner_without_listener * x_a

      _subject_module.via_array x_a
    end

    def expression_agent
      Home_::API::ArgumentScannerExpressionAgent.instance
    end

    def _subject_module
      Home_::API::ArgumentScanner
    end
  end
end
