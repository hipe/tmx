require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] models (public) - primaries injections" do

    # this work falls under the mandate of [#ze-053] (and is based exactly
    # on architecture designed and specified there) but see that document
    # for why this test is here for now.

    TS_[ self ]
    use :memoizer_methods
    use :primaries_injections

    context "no crossover in primaries, two primaries only" do

      context "one intended for the higher-level injector goes there" do

        it "succeeds" do
          expect_succeeded_
        end

        it "wrote" do
          clientesque_.color == :red || fail
        end

        shared_subject :executed_tuple_ do
          given_arguments_ :color, :red
          build_executed_tuple_
        end
      end

      context "one intended for the lower-level injector goes there" do

        it "succeeds" do
          expect_succeeded_
        end

        it "wrote" do
          operationesque_.shape == :square || fail
        end

        shared_subject :executed_tuple_ do
          given_arguments_ :shape, :square
          build_executed_tuple_
        end
      end

      memoize :these_two_primaries_hashes_ do
        a = []
        a.push( shape: :_at_shape )
        a.push( color: :_at_color )
        a
      end
    end

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

      @ARG_SCN = TS_::Primaries_Injections::ArgumentScannerForTesting.
        new x_a, & p
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

      arg_scn = __flush_argument_scanner

      op = lib::Operation.new arg_scn
      cli = lib::Client.new arg_scn

      _prim_for_op = operationesque_primaries_
      _prim_for_client = clientesque_primaries_

      _xx = _subject_module.call_by do |o|
        o.argument_scanner arg_scn
        o.add_primaries_injection _prim_for_op, op
        o.add_primaries_injection _prim_for_client, cli
      end

      X_pmo_pi_execution_result[ _xx, cli, op ]
    end

    def __flush_argument_scanner
      remove_instance_variable :@ARG_SCN
    end

    X_pmo_pi_execution_result = ::Struct.new :result, :clientesque, :operationesque

    def _subject_module
      Home_::Mondrian_[]::ParseArguments_via___
    end
  end
end
