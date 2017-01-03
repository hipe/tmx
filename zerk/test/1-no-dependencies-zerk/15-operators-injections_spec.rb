require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[cm] no deps - operators injections" do

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk
    use :no_dependencies_zerk_features_injections

    context "against CLI head that looks like operator and is" do

      context "parsing softly" do

        it "succeeds" do
          _parsation.result || fail
        end

        it "advances scanner" do
          _parsation.scanner.head_as_is == "zz" || fail
        end
      end

      context "and the lookup" do

        it "you can see the business value from the find result" do
          _findation.result.mixed_business_value == :zzz || fail
        end

        it "you can reach the injector from the find result" do
          _findation.result.injector == :_INJECTOR_2_ || fail
        end
      end

      shared_subject :_findation do
        _flush_findation
      end

      shared_subject :_parsation do
        _against_CLI_arguments 'xx-yy2', 'zz'
        _flush_parsation
      end

      def _subject_omni
        _frozen_omni_one
      end
    end

    # == shared singletons

    shared_subject :_frozen_omni_one do

      _OPERATIONS = {
        xx: :yy,
      }

      _PRIMARIES = {
        zz: :qq,
      }

      _ = subject_library_::ParseArguments_via_FeaturesInjections.define do |fi|

        fi.add_hash_based_operators_injection _OPERATIONS, :_no_

        fi.add_lazy_operators_injection_by do |o|
          _h = {
            xx_yy1: :xxx,
            he_ha: :yyy,
          }
          o.operators = Home_::ArgumentScanner::OperatorBranch_via_Hash[ _h ]
          o.injector = :_INJECTOR_1_
        end

        fi.add_lazy_operators_injection_by do |o|
          _h = {
            xx_yy2: :zzz,
          }
          o.operators = Home_::ArgumentScanner::OperatorBranch_via_Hash[ _h ]
          o.injector = :_INJECTOR_2_
        end

        fi.add_primaries_injection _PRIMARIES, :_nerp_
      end

      _.freeze
    end

    # == setup support

    def _against_CLI_arguments * s_a, & p
      @argument_scanner = subject_library_::CLI_ArgumentScanner.new s_a, & p
      NIL
    end

    def _flush_findation
      o = _parsation
      _x = o.omni.flush_to_lookup_operator
      X_ndz_oi_Findation[ _x, o.log ]
    end

    def _flush_parsation log=nil
      omni = _dup_and_mutate_omni
      _x = omni.parse_operator_softly
      X_ndz_oi_Parsation[ log, @argument_scanner, omni, _x ]
    end

    def _dup_and_mutate_omni
      _omni = _subject_omni
      mutable = _omni.send :dup  # eew
      mutable.argument_scanner argument_scanner
      mutable
    end

    def _build_new_event_log
      Common_.test_support::Expect_Emission::Log.for self
    end

    def argument_scanner
      @argument_scanner
    end

    # --

    X_ndz_oi_Findation = ::Struct.new :result, :log
    X_ndz_oi_Parsation = ::Struct.new :log, :scanner, :omni, :result

    # ==
  end
end
