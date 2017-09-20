# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe '[ze] no deps - optional arguments' do

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk_features_injections

    context 'when arg YES provided' do

      given do
        args_for_API :er_der, :anything
        args_for_CLI '-er-der', 'hurr durr'
      end

      it 'see arg in API' do
        _vm = value_match_for_API_
        _vm.mixed == :anything || fail
      end

      it 'see arg in CLI' do
        _vm = value_match_for_CLI_
        _vm.mixed == 'hurr durr'
      end
    end

    context 'when arg not provided because end of stream' do

      given do
        args_for_API :er_der
        args_for_CLI '-er-der'
      end

      it 'you could default in API' do
        _vm = value_match_for_CLI_
        _vm.nil? || fail
      end

      it 'you could default in CLI' do
        _vm = value_match_for_API_
        _vm.nil? || fail
      end
    end

    context 'money shot: arg not provided, primary follows (CLI ONLY)' do

      given do
        args_for_CLI '-er-der', '-other-guy'
      end

      it 'gets both primaries in CLI' do
        _vm = value_match_for_CLI_
        _vm.primary_symbol == :other_guy || fail
      end

      def story_time_ nar
        __this_other_story nar
      end
    end

    def __this_other_story nar
      prim_match = _common_prim_match nar
      vm = nar.match_optional_argument_after_feature_match prim_match
      vm && fail
      nar.advance_past_match prim_match
      _vm = nar.match_primary_shaped_token
      [ :story_ZE, _vm ]
    end

    def story_time_ nar
      prim_match = _common_prim_match nar
      _vm = nar.match_optional_argument_after_feature_match prim_match
      _common_finish _vm, nar
    end

    def _common_prim_match nar
      prim_match = nar.procure_primary_shaped_match
      prim_match || fail
      prim_match.primary_symbol == :er_der || fail
      prim_match
    end

    def _common_finish vm, nar
      _advance_over_any_last_match vm, nar
      [ :story_ZE, vm ]
    end

    def _advance_over_any_last_match ma, nar
      if ma
        nar.advance_past_match ma
        nar.token_scanner.no_unparsed_exists || fail
      end
    end

    # ==
    # ==
  end
end
# #born in 2nd wave
