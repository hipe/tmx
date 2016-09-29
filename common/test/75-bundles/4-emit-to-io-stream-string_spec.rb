require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] bundles - emit via simple IO manifold" do

    TS_[ self ]

    context "minimal" do

      before :all do
        class X_b_etiss_Foo
          Home_[ self, :emit_to_IO_stream_string ]
          def initialize dbg_IO
            @fun_IO = TestSupport_::IO.spy(
              :do_debug, ( dbg_IO ? true : false ),
              :debug_IO, dbg_IO )
            init_simple_IO_manifold fun: @fun_IO ; nil
          end
          attr_reader :fun_IO

          def emt i, s
            emit_to_IO_stream_string i, s
          end
        end
      end

      it "loads" do
      end

      it "builds" do
        foo
      end

      it "emits to a good channel, result is nil, adds newline - o" do
        r = foo.emt :fun, "yeppers"
        r.should be_nil
        @foo.fun_IO.string.should eql "yeppers\n"
      end

      it "when bad channel - X" do

        _s = "no such stream 'fran'. did you mean 'fun'?"

        begin
          foo.emt :fran, "doikey"
        rescue ::KeyError => e
        end

        e.message == _s || fail
      end

      def foo
        @foo ||= build_foo
      end

      def build_foo
        X_b_etiss_Foo.new do_debug && debug_IO
      end
    end
  end
end
