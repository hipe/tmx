module Skylab::Zerk::TestSupport

  module No_Dependencies_Zerk::Features_Injections

    def self.[] tcc
      tcc.include InstanceMethods___
    end

    module InstanceMethods___

      # -- expect

      def expect_succeeded_
        executed_tuple_.result || fail
      end

      def clientesque_
        executed_tuple_.clientesque
      end

      def operationesque_
        executed_tuple_.operationesque
      end

      # -- shared state support

      def parsation_via_ x, omni, log
        Parsation___.new x, omni, log
      end

      def flush_one_emission_via_findation_
        log = findation_.log
        em = log.gets
        log.gets and fail
        em
      end

      def findation_via_ x, omni, log
        Findation___.new x, omni, log
      end

      # -- setup

      def dup_and_mutate_omni_
        _omni = subject_omni_
        mutable = _omni.send :dup  # eew
        mutable.argument_scanner = argument_scanner_
        mutable
      end

      def frozen_omni_one_
        Frozen_omni_one___[]
      end

      def against_CLI_arguments_ * s_a, & p
        @argument_scanner = subject_library_::CLI_ArgumentScanner.new s_a, & p
        NIL
      end

      def given_arguments_ * x_a, & p

        _cls = TS_::No_Dependencies_Zerk::Argument_scanner_for_testing[]
        @argument_scanner = _cls.new x_a, & p
        NIL
      end

      def build_new_event_log_
        Common_.test_support::Expect_Emission::Log.for self
      end

      def clientesque_primaries_
        these_two_primaries_hashes_.fetch 1
      end

      def operationesque_primaries_
        these_two_primaries_hashes_.fetch 0
      end

      def build_executed_tuple_

        lib = library_one_

        arg_scn = argument_scanner_

        op = lib::Operation.new arg_scn
        cli = lib::Client.new arg_scn

        _prim_for_op = operationesque_primaries_
        _prim_for_client = clientesque_primaries_

        _xx = subject_library_::ParseArguments_via_FeaturesInjections.define do |o|
          o.argument_scanner = arg_scn
          o.add_primaries_injection _prim_for_op, op
          o.add_primaries_injection _prim_for_client, cli
        end.flush_to_parse_primaries

        ExectionResult___[ _xx, cli, op ]
      end

      def argument_scanner_
        remove_instance_variable :@argument_scanner
      end
    end

    # ==

    Frozen_omni_one___ = Lazy_.call do

      _OPERATIONS = {
        xx: :yy,
      }

      _PRIMARIES = {
        zz: :__parse_zz,
      }


      _lib = No_Dependencies_Zerk::Subject_library_[]

      _ = _lib::ParseArguments_via_FeaturesInjections.define do |fi|

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

    # ==

    class Parsation___

      def initialize x, omni, log
        @log = log
        @omni = omni
        @result = x
      end

      def scanner
        @omni.argument_scanner
      end

      attr_reader :log, :omni, :result
    end

    ExectionResult___ = ::Struct.new :result, :clientesque, :operationesque

    Findation___ = ::Struct.new :result, :omni, :log

    # ==
  end
end
# #history: abstracted from a test
