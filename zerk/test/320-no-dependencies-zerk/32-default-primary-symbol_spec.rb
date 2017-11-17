# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe '[ze] no deps - default primary symbol' do

    # :#Coverpoint1.6: this is meant to be identical to production grammar
    # in [ts]. the purpose is to demonstrate default primary symbols.

    # "default primary symbol" is a sort of hackish way to achieve a subset
    # of familiar CLI interfaces, the kind that accepts zero or more non
    # "option" looking tokens as well as arbitrary options

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk
    use :no_dependencies_zerk_features_injections

    context 'parse two doo-hahs using the default primary' do

      it 'succeeds' do
        succeeds_
      end

      it 'reached end of scanner' do
        reached_end_of_scanner_
      end

      shared_subject :parsation_ do
        against_CLI_arguments_ 'tom1', 'tom2'
        _flush_parsation
      end
    end

    context 'empty OK' do

      it 'succeeds' do
        succeeds_
      end

      shared_subject :parsation_ do
        against_CLI_arguments_
        _flush_parsation
      end
    end

    context 'you can still use the primary' do

      it 'succeeds' do
        succeeds_
      end

      it 'reached end of scanner' do
        reached_end_of_scanner_
      end

      shared_subject :parsation_ do
        against_CLI_arguments_ '-perth-olio', 'tom1', '-perth-olio', 'tom2'
        _flush_parsation
      end
    end

    context 'you can intersperse this mechanic with other primaries' do

      it 'succeeds' do
        succeeds_
      end

      it 'reached end of scanner' do
        reached_end_of_scanner_
      end

      shared_subject :parsation_ do
        against_CLI_arguments_ 'tom1', '-chimmy-chonga', 'tom2'
        _flush_parsation
      end
    end

    # -- assertions (abstraction candidates)

    def succeeds_
      parsation_.result == true || fail
    end

    def reached_end_of_scanner_
      parsation_.token_scanner.no_unparsed_exists || fail
    end

    # --

    def _flush_parsation log=nil

      omni = dup_and_mutate_omni_
      nar = omni.argument_scanner_narrator
      ts = nar.token_scanner

      unless ts.no_unparsed_exists
        primary_match = nar.match_primary_shaped_token
      end

      _x = if primary_match

        omni.flush_to_find_and_process_this_and_remaining_primaries primary_match

      elsif ts.no_unparsed_exists

        ACHIEVED_

      else
        omni.flush_to_parse_primaries
      end

      parsation_via_ _x, omni, log
    end

    def subject_omni_
      X_nodeps_dp_Frozen_omni_one___[]
    end

    X_nodeps_dp_Frozen_omni_one___ = Lazy_.call do

      lib = No_Dependencies_Zerk::Subject_library_[]

      _fb = Home_.lib_.basic::Module::FeatureBranch_via_Module.define do |o|
        o.module = X_nodeps_dp_Plergins
        # o.sub_branch_const = :Erksherns
      end

      lib::ArgumentParsingIdioms_via_FeaturesInjections.define do |o|

        o.add_lazy_primaries_injection_by do |inj|

          inj.parse_by = -> prim_found, omni do

            _one_of_these = prim_found.trueish_feature_value.const_value  # #here1

            _ok = _one_of_these[ prim_found, omni ]

            _ok
          end

          inj.primaries = _fb
        end

        o.default_primary_symbol = :perth_olio
      end
    end

    module X_nodeps_dp_Plergins

      # NOTE naming is important - for now we can't use underscores or all caps

      PerthOlio = -> prim_found, omni do  # for `perth_olio`

        nar = omni.argument_scanner_narrator
        value_match = nar.procure_any_match_after_feature_match prim_found.feature_match

        if value_match
          nar.advance_past_match value_match
        end
      end

      ChimmyChonga = -> prim_found, omni do

        omni.argument_scanner_narrator.advance_past_match prim_found.feature_match
      end

      # above :#here1
    end

    # ==
    # ==
  end
end
# #born in 2nd wave
