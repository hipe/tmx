# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe '[ze] no deps - parsing values' do

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk_features_injections

    context 'any when falseish' do

      given do
        args_for_API :chimmy_chonga, nil
      end

      it 'works' do
        _vm = value_match_for_API_
        _vm.mixed.nil? || fail
      end

      def story_time_ nar
        _story_time_for_any nar
      end
    end

    context 'any when fail' do

      given do
        args_for_API :chimmy_chonga
        args_for_CLI '-chimmy-chonga'
        expect_failure
      end

      it 'fails in API' do
        _line = one_line_for_API_
        _line == %q('chimmy_chonga' requires an argument) || fail
      end

      it 'fails in CLI' do
        _line = one_line_for_CLI_
        _line == '-chimmy-chonga requires an argument' || fail
      end

      def story_time_ nar
        _story_time_for_any nar
      end
    end

    def _story_time_for_any nar

      prim_match = nar.procure_primary_shaped_match
      prim_match || fail
      _vm = nar.procure_any_match_after_feature_match prim_match
      _common_finish _vm, nar
    end

    context 'trueish when yes' do

      given do
        args_for_API :chimmy_chonga, 23
        args_for_CLI '-chimmy-chonga', '23'
      end

      it 'works for API' do
        value_for_API_ == 23 || fail
      end

      it 'works for CLI' do
        value_for_CLI_ == '23' || fail
      end

      def story_time_ nar
        _story_time_for_trueish nar
      end
    end

    context 'trueish when fails' do

      given do
        args_for_API :chimmy_chonga, nil
        expect_failure
      end

      it 'fails for API' do
        _line = one_line_for_API_
        _line == %q{'chimmy_chonga' must be trueish (had nil)} || fail
      end

      def story_time_ nar
        _story_time_for_trueish nar
      end
    end

    def _story_time_for_trueish nar

      prim_match = nar.procure_primary_shaped_match
      prim_match || fail
      _vm = nar.procure_trueish_match_after_feature_match prim_match
      _common_finish _vm, nar
    end

    context 'regex when yes' do

      given do
        args_for_API :chimmy_chonga, 'Fonsi'
        args_for_CLI '-chimmy-chonga', 'Cardi'
      end

      it 'works for API' do
        _vm = value_match_for_API_
        _vm.mixed[1] == 'onsi' || fail
      end

      it 'works for CLI' do
        _vm = value_match_for_CLI_
        _vm.mixed[1] == 'ardi' || fail
      end

      def story_time_ nar
        _story_time_for_regex nar
      end
    end

    context 'regex when fails (no custom message)' do

      given do
        args_for_API :chimmy_chonga, 'fonsi'
        args_for_CLI '-chimmy-chonga', 'cardi'
        expect_failure
      end

      it 'fails for API' do
        _line = one_line_for_API_
        _line == %q{"fonsi" is not a valid 'chimmy_chonga'} || fail
      end

      it 'fails for CLI' do
        _line = one_line_for_CLI_
        _line == %q{"cardi" is not a valid -chimmy-chonga} || fail
      end

      def story_time_ nar
        _story_time_for_regex nar
      end
    end

    def _story_time_for_regex nar

      prim_match = nar.procure_primary_shaped_match
      prim_match || fail
      _vm = nar.procure_matching_match_after_feature_match %r(\A[A-Z]([a-z]+)\z), prim_match
      _common_finish _vm, nar
    end

    context 'regex when fails (YES custom message)' do

      given do
        args_for_API :chimmy_chonga, 'fonsi'
        args_for_CLI '-chimmy-chonga', 'cardi'
        expect_failure
      end

      it 'fails for API' do
        _line = one_line_for_API_
        _line == %q{'chimmy_chonga' must match /\A[A-Z]/ (had "fonsi")} || fail
      end

      it 'fails for CLI' do
        _line = one_line_for_CLI_
        _line == %q{-chimmy-chonga must match /\A[A-Z]/ (had "cardi")} || fail
      end

      def story_time_ nar
        _story_time_for_regex_with_message nar
      end
    end

    def _story_time_for_regex_with_message nar

      prim_match = nar.procure_primary_shaped_match
      prim_match || fail
      rx = %r(\A[A-Z])
      _vm = nar.procure_matching_match_after_feature_match rx, prim_match do
        "{{ feature }} must match /#{ rx.source }/ (had {{ mixed_value }})"
      end
      _common_finish _vm, nar
    end

    context 'integer fails (shape/type)' do

      given do
        args_for_API :human_age, '1'
        args_for_CLI '-human-age', 'one'
        expect_failure
      end

      it 'fails for API' do
        _line = one_line_for_API_
        _line == %q{'human_age' must be integer type (was String): "1"} || fail
      end

      it 'fails for CLI' do
        _line = one_line_for_CLI_
        _line == '-human-age does not look like integer: "one"' || fail
      end

      def story_time_ nar
        _story_time_for_integer nar
      end
    end

    context 'integer fails (range)' do

      given do
        args_for_API :human_age, 0
        args_for_CLI '-human-age', '0'
        expect_failure
      end

      it 'fails for API' do
        _line = one_line_for_API_
        _line == %q{'human_age' must be positive nonzero (had 0)} || fail
      end

      it 'fails for CLI' do
        _line = one_line_for_CLI_
        _line == %q{-human-age must be positive nonzero (had 0)} || fail
      end

      def story_time_ nar
        _story_time_for_integer nar
      end
    end

    context 'integer succees' do

      given do
        args_for_API :human_age, 1
        args_for_CLI '-human-age', '3'
      end

      it 'works for API' do
        _vm = value_match_for_API_
        _vm.mixed == 1 || fail
      end

      it 'works for CLI' do
        _vm = value_match_for_CLI_
        _vm.mixed == 3 || fail
      end

      def story_time_ nar
        _story_time_for_integer nar
      end
    end

    def _story_time_for_integer nar

      fm = nar.procure_primary_shaped_match
      fm || fail

      _vm = nar.procure_positive_nonzero_integer_after_feature_match fm

      _common_finish _vm, nar
    end

    # ==

    def _common_finish vm, nar
      if vm
        nar.advance_past_match vm
        nar.token_scanner.no_unparsed_exists || fail
      end
      [ :story_ZE, vm ]
    end

    # ==
    # ==
  end
end
# #born in 2nd wave
