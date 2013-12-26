require_relative 'test-support'

module Skylab::PubSub::TestSupport::Bundles

  describe "[ps] bundles - emit via simple IO manifold" do

    extend TS__

    context "minimal" do

      before :all do
        class Foo_EVSIM
          PubSub[ self, :emit_via_simple_IO_manifold ]
          def initialize dbg_IO
            @fun_IO = TestSupport::IO::Spy.standard do |io|
              io.any_debug_IO_notify dbg_IO
            end
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
        -> do
          foo.emt :fran, "doikey"
        end.should raise_error ::KeyError,
          "no such stream 'fran'. did you mean 'fun'?"
      end

      def foo
        @foo ||= build_foo
      end
      def build_foo
        Foo_EVSIM.new any_relevant_debug_IO
      end
    end
  end
end
