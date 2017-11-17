require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - argument scanner" do

    TS_[ self ]
    use :memoizer_methods
    use :want_emission_fail_early

    it "loads." do
      _subject_module
    end

    common_hash = { wiz_biffle: :_no_see_, y: :_no_see_ }

    context "if the first term is not a symbol.." do

      it "fails" do
        _message_lines
      end

      it "says unknown primary **as string (as received)**" do
        _message_lines.first == 'unknown primary "wiz_biffle"' || fail
      end

      it "offers the alternatives" do
        _message_lines.last == "expecting :wiz_biffle or :y" || fail
      end

      shared_subject :_message_lines do

        _as = _build_argument_scanner_with_listener "wiz_biffle"

        call_by do

          branch_value_via_match_primary_against_ _as, common_hash
        end

        y = nil
        want :error, :expression, :parse_error, :expected_symbol do |y_|
          y = y_
        end

        want_result UNABLE_

        if 1 == y.length
          y = Hackily_unwrap_wrapped_line_[ y[0] ]
        end

        y
      end
    end

    it "parse a primary against a hash" do

      _as = _build_argument_scanner_without_listener :x, :_no_see_

      _x = branch_value_via_match_primary_against_ _as, x: :_money_

      _x == :_money_ || fail
    end

    context "if value is expected and the input ends" do

      it "fails" do
        _message_lines
      end

      it "whines" do
        _y = _message_lines
        _y == [ ":zim_zum must be followed by an argument" ] || fail
      end

      shared_subject :_message_lines do

        as = _build_argument_scanner_with_listener

        as.instance_variable_set :@current_primary_symbol, :zim_zum

        call_by do
          as.parse_primary_value
        end

        _want_failure_and_produce_lines(
          :error, :expression, :primary_parse_error, :primary_value_not_provided )
      end
    end

    context "if the value is nil and you pass no arguments.." do

      it "result is a knownness" do
        _kn_and_as.first.value.nil? || fail
      end

      it "arg scanner is empty" do
        _kn_and_as.last.no_unparsed_exists || fail
      end

      shared_subject :_kn_and_as do

        as = _build_argument_scanner_without_listener nil

        _kn = as.parse_primary_value

        [ _kn, as ]
      end
    end

    it "parse that value" do

      as = _build_argument_scanner_without_listener :x, :_money_two_

      _x = branch_value_via_match_primary_against_ as, x: :_money_one_

      _x == :_money_one_ || fail  # redundant with previous test

      as.advance_one

      _kn = as.parse_primary_value
      _xx = _kn.value
      _xx == :_money_two_ || fail
    end

    context "if the value is nil and say `must_be_trueish`" do

      it "fails" do
        _message_lines
      end

      it "one line talking 'bout must be true" do
        _y = _message_lines
        _y == [ "must be trueish: nil" ] || fail
      end

      shared_subject :_message_lines do

        _as = _build_argument_scanner_with_listener nil

        call_by do
          _as.parse_primary_value :must_be_trueish
        end

        _want_failure_and_produce_lines(
          :error, :expression, :primary_parse_error, :not_trueish )
      end
    end

    context "not an integer" do

      it "fails" do
        _message_lines
      end

      it "one line talking 'bout not an integer" do
        _y = _message_lines
        _y == [ 'must be integer: "not-an-int"' ] || fail
      end

      shared_subject :_message_lines do

        _as = _build_argument_scanner_with_listener 'not-an-int'

        call_by do
          _as.parse_primary_value :must_be_integer_that_is_non_negative
        end

        _want_failure_and_produce_lines(
          :error, :expression, :primary_parse_error, :not_integer )
      end
    end

    context "integer out of range" do

      it "fails" do
        _message_lines
      end

      it "one line talking 'bout out of range" do
        _y = _message_lines
        _y == [ "must be positive nonzero: 0" ] || fail
      end

      shared_subject :_message_lines do

        _as = _build_argument_scanner_with_listener 0

        call_by do
          _as.parse_primary_value :must_be_integer_that_is_positive_nonzero
        end

        _want_failure_and_produce_lines(
          :error, :expression, :primary_parse_error, :not_positive_nonzero )
      end
    end

    context "fancy custom thing" do

      it "fails" do
        _message_lines
      end

      it "one line talking 'bout out of range" do
        _y = _message_lines
        _y == [ ":wiz_biffle must be at least 2 (had 1)" ] || fail
      end

      shared_subject :_message_lines do

        as = _build_argument_scanner_with_listener :wiz_biffle, 1

        _k = as.match_branch :primary, :against_hash, common_hash
        _k || fail
        as.advance_one

        call_by do
          __call_this_one_custom_parser as
        end

        _want_failure_and_produce_lines(
          :error, :expression, :primary_parse_error, :custom_wazoozle_range )
      end
    end

    def __call_this_one_custom_parser as

      min = 2

      _d = as.parse_primary_value :must_be_integer, :must_be do |d, o|
        if min <= d
          d
        else
          o.primary_parse_error :custom_wazoozle_range do |y|
            _ = o.subject_moniker
            y << "#{ _ } must be at least #{ min } (had #{ d })"
          end
        end
      end
      _d  # #todo
    end

    def _want_failure_and_produce_lines * sym_a
      y = nil
      want_on_channel sym_a do |y_|
        y = y_
      end
      want_result UNABLE_
      y
    end

    def _build_argument_scanner_with_listener * x_a

      _l = want_emission_fail_early_listener
      _subject_module.via_array x_a, & _l
    end

    def _build_argument_scanner_without_listener * x_a

      _subject_module.via_array x_a
    end

    def branch_value_via_match_primary_against_ as, h
      as.match_branch :primary, :value, :against_hash, h
    end

    def expression_agent
      Home_::API::ArgumentScannerExpressionAgent.instance
    end

    def _subject_module
      Home_::API::ArgumentScanner
    end
  end
end
