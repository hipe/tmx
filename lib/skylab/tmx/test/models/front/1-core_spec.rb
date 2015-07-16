require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] models - front" do

    extend TS_
    use :models_reactions

    # three laws all the way.

    # a "front" is a long-running daemon that receives requests

    it "loads" do
      subject_module_
    end

    context "on the empty guy" do

      it "when none - whine about it this way" do

        build_and_call_
        ev = expect_failed_by :missing_first_argument
        black_and_white( ev ).should eql _there_are_none
      end

      it "when arg - whine about anything" do

        build_and_call_ :wazoozle, :shanoozle

        ev = expect_failed_by :no_such_reactive_node

        black_and_white_lines( ev ).should eql( [
          _unrec_wazoozle,
          _there_are_none ] )
      end

      dangerous_memoize_ :front_ do

        o = subject_module_.new( & method( :fail ) )
        o.fast_lookup = -> _ do end  # MONADIC_EMPTINESS_
        o.unbound_stream_builder = -> do
          Callback_::Stream.the_empty_stream
        end
        o
      end
    end

    context "with two nodes" do

      it "when none - whine about it this other way" do

        build_and_call_
        ev = expect_failed_by :missing_first_argument
        black_and_white( ev ).should eql "missing first argument."
      end

      it "when one strange - xx" do

        build_and_call_ :wazoozle, :shanoozle

        ev = expect_failed_by :no_such_reactive_node
        black_and_white_lines( ev ).should eql( [
          _unrec_wazoozle,
          'expecting "AAzzAA" or "BBzzBB"' ] )
      end

      dangerous_memoize_ :front_ do

        box = Callback_::Box.new
        box.add :finkle_A, _unbound_A
        box.add :finkle_B, _unbound_B

        o = subject_module_.new( & method( :fail ) )

        o.fast_lookup = -> sym do

          box[ sym ]
        end

        o.unbound_stream_builder = -> do

          box.to_value_stream
        end

        o
      end
    end

    dangerous_memoize_ :_unbound_A do
      build_mock_unbound_ :AAzzAA
    end

    dangerous_memoize_ :_unbound_B do
      build_mock_unbound_ :BBzzBB
    end

    memoize_ :_unrec_wazoozle do
      "unrecognized argument 'wazoozle'"
    end

    memoize_ :_there_are_none do
      "there are no reactive nodes."
    end
  end
end
