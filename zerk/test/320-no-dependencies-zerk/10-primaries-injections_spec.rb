require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] no deps - primaries injections" do

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk
    use :no_dependencies_zerk_features_injections

    context "no crossover in primaries, two primaries only" do

      context "one intended for the higher-level injector goes there" do

        it "succeeds" do
          want_succeeded_
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
          want_succeeded_
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

    # ==

    # ==
  end
end
