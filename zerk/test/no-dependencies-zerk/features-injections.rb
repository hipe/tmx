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

      # -- setup

      def given_arguments_ * x_a, & p

        _cls = TS_::No_Dependencies_Zerk::Argument_scanner_for_testing[]
        @argument_scanner = _cls.new x_a, & p
        NIL
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

    ExectionResult___ = ::Struct.new :result, :clientesque, :operationesque

    # ==
  end
end
# #history: abstracted from a test
