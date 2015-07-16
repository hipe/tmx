require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] models - front - 2" do

    extend TS_
    use :models

    context "with two nodes" do

      it "when one money" do

        build_and_call_ :wiznizzie, :shanoozle
        expect_no_events
        :xxXXxx == @result or fail
      end

      dangerous_memoize_ :build_front_ do

        box = Callback_::Box.new
        box.add :wiznizzie, _unbound_W

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

    dangerous_memoize_ :_unbound_W do

      mod = build_mock_unbound_ :Wizzie

      TS_::Models_02_Wizzie = mod

      cls = build_shanoozle_into_ mod

      cls.send :define_method, :produce_result do
        :xxXXxx
      end

      mod
    end
  end
end
