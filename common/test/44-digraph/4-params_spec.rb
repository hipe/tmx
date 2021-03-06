require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] digraph params - when your handler takes" do

    TS_[ self ]
    use :the_method_called_let
    use :digraph

    klas = instance_method :klass

    kls = nil

    define_method :klass do
      kls ||= begin                   # (just derking around with alias
        kl = klas.bind( self ).call   # method chains: functional edition)
        kl.send :listeners_digraph, :bar
        kl
      end
    end

    let :canary do { } end

    context "a variable (*) number of args, and you call_digraph_listeners" do

      let :emitter do
        o = klass.new
        o.on_bar do |*a|
          canary[:args] = a
        end
        o
      end

      it "0 payload args - handler gets 0 args" do
        emitter.call_digraph_listeners :bar
        expect( canary[:args] ).to eql( [] )
      end

      it "1 payload arg - handler gets 1 arg" do
        emitter.call_digraph_listeners :bar, 'foo'
        expect( canary[:args] ).to eql( ['foo'] )
      end

      it "2 payload args - handler gets 2 args" do
        emitter.call_digraph_listeners :bar, 'one', 2
        expect( canary[:args] ).to eql( ['one', 2] )
      end
    end

    context "exactly one arg, call_digraph_listeners" do

      let :emitter do
        o = klass.new
        o.on_bar do |one|
          canary[:arg] = one
        end
        o
      end

      it "0 payload args - handler gets 1 event object, with a nil payload" do
        emitter.call_digraph_listeners :bar
        expect( canary[:arg].payload_a ).to eql( nil )
      end

      it "1 payload arg - handler gets 1 event object" do
        emitter.call_digraph_listeners :bar, 'foo'
        expect( canary[:arg].payload_a.first ).to eql( 'foo' )
      end

      it "2 payload args - handler gets 1 event obj with 2 args arr in p.l" do
        emitter.call_digraph_listeners :bar, 'foo', 'baz'
        expect( canary[:arg].payload_a ).to eql( ['foo', 'baz'] )
      end
    end

    context "exactly two arguments, call_digraph_listeners" do
      let :emitter do
        o = klass.new
        o.on_bar do |a, b|
          canary[:args] = [a, b]
        end
        o
      end

      it "0 payload args - handler gets 2 nils" do
        emitter.call_digraph_listeners :bar
        expect( canary[:args] ).to eql( [nil, nil] )
      end

      it "1 payload arg - handler gets the 1 arg and 1 nil" do
        emitter.call_digraph_listeners :bar, 'foo'
        expect( canary[:args] ).to eql( ['foo', nil] )
      end

      it "2 payload args - handler gets the two" do
        emitter.call_digraph_listeners :bar, 'one', 2
        expect( canary[:args] ).to eql( ['one', 2] )
      end
    end
  end
end
