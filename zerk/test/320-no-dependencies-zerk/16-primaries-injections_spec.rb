require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[cm] no deps - primaries injections" do

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk
    use :no_dependencies_zerk_features_injections

    # == 1

    context "against CLI head that looks like an operator (and is)" do

      context "parsing softly" do

        it "does not parse" do
          parsation_.result.nil? || fail
        end

        it "does not advance scanner" do
          parsation_.scanner.head_as_is == "xx-yy2" || fail
        end
      end

      shared_subject :parsation_ do
        against_CLI_arguments_ 'xx-yy2', 'zz'
        _flush_parsation
      end
    end

    # == 2

    context "against CLI head that looks like a primary but isn't" do

      context "parsing softly" do

        it "succeeds" do
          parsation_.result || fail
        end

        it "advances scanner" do
          parsation_.scanner.head_as_is == "zz" || fail
        end
      end

      context "but the lookup" do

        it "did not find" do
          _x = findation_.result
          _x.nil? || fail
        end

        it "emits a `primary_parse_error` (not a parse error)" do

          _emission.channel_symbol_array[2] == :primary_parse_error || fail
        end

        it "first line - unrec" do

          _lines.first == "unknown primary \"-xx-yy2\"" || fail
        end

        it "second and final line - splay of ONLY available primaries" do

          a = _lines

          a.last =~ %r(\Aavailable primar(?:y|ies): -zz\z) || fail

          2 == a.length || fail
        end

        shared_subject :_lines do
          _emission.express_into_under [], expression_agent
        end

        shared_subject :_emission do
          flush_one_emission_via_findation_
        end
      end

      shared_subject :findation_ do
        _flush_findation
      end

      shared_subject :parsation_ do
        log = build_new_event_log_
        against_CLI_arguments_ '-xx-yy2', 'zz', & log.handle_event_selectively
        _flush_parsation log
      end
    end

    # == 3

    context "against CLI head that looks like a primary and is" do

      context "parsing softly" do

        it "succeeds" do
          parsation_.result || fail
        end

        it "advances scanner" do
          parsation_.scanner.head_as_is == "qq" || fail
        end
      end

      context "and the flushing of the rest of the parse" do

        it "the parse succeeds" do
          findation_.result == true || fail
        end

        it "the injector received the value" do
          _ = findation_
          _inj = _.omni.__PRIMARIES_INJECTOR
          _inj.ZZ == 'qq' || fail
        end
      end

      shared_subject :findation_ do
        _flush_findation
      end

      shared_subject :parsation_ do
        against_CLI_arguments_ '-zz', 'qq'
        _flush_parsation
      end

      def produce_omni_
        __build_real_omni
      end
    end

    # ==

    def _flush_findation
      o = parsation_
      _x = o.omni.flush_to_lookup_current_and_parse_remaining_primaries
      findation_via_ _x, o.omni, o.log
    end

    def _flush_parsation log=nil
      omni = produce_omni_
      _x = omni.scan_primary_symbol_softly
      parsation_via_ _x, omni, log
    end

    def produce_omni_
      dup_and_mutate_omni_
    end

    def __build_real_omni

      _OPERATIONS = {
        xx: :yy,
      }

      _PRIMARIES = {
        zz: :__parse_zz,
      }
      _args = remove_instance_variable :@argument_scanner

      primary_injector = X_nodes_PrimaryInjectorTwo___.new _args

      _lib = No_Dependencies_Zerk::Subject_library_[]

      omni = _lib::ParseArguments_via_FeaturesInjections.define do |fi|

        fi.add_hash_based_operators_injection _OPERATIONS, :_no_

        fi.add_lazy_operators_injection_by do |o|
          _h = {
            xx_yy2: :zzz,
          }
          o.operators = Home_::ArgumentScanner::OperatorBranch_via_Hash[ _h ]
          o.injector = :_INJECTOR_2_
        end

        fi.add_primaries_injection _PRIMARIES, primary_injector

        fi.argument_scanner = _args
      end

      omni.send :define_singleton_method, :__PRIMARIES_INJECTOR do
        primary_injector
      end

      omni
    end

    def subject_omni_
      frozen_omni_one_
    end

    # == setup support

    def expression_agent
      expression_agent_for_nodeps_CLI_
    end

    # ==

    class X_nodes_PrimaryInjectorTwo___

      def initialize scn
        @_scn = scn
      end

      def __parse_zz
        @ZZ = @_scn.head_as_is
        @_scn.advance_one
        ACHIEVED_
      end

      attr_reader :ZZ
    end

    # ==
  end
end
