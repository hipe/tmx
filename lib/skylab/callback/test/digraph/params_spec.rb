require_relative 'test-support'

module ::Skylab::Callback::TestSupport::Emitter

  describe "[cb] emitter params - when your handler takes" do

    extend Emitter_TestSupport

    klas = instance_method :klass

    kls = nil

    define_method :klass do
      kls ||= begin                   # (just derking around with alias
        kl = klas.bind( self ).call   # method chains: functional edition)
        kl.send :emits, :bar
        kl
      end
    end

    let :canary do { } end

    context "a variable (*) number of args, and you emit" do

      let :emitter do
        o = klass.new
        o.on_bar do |*a|
          canary[:args] = a
        end
        o
      end

      it "0 payload args - handler gets 0 args" do
        emitter.emit :bar
        canary[:args].should eql( [] )
      end

      it "1 payload arg - handler gets 1 arg" do
        emitter.emit :bar, 'foo'
        canary[:args].should eql( ['foo'] )
      end

      it "2 payload args - handler gets 2 args" do
        emitter.emit :bar, 'one', 2
        canary[:args].should eql( ['one', 2] )
      end
    end

    context "exactly one arg, emit" do

      let :emitter do
        o = klass.new
        o.on_bar do |one|
          canary[:arg] = one
        end
        o
      end

      it "0 payload args - handler gets 1 event object, with a nil payload" do
        emitter.emit :bar
        canary[:arg].should be_kind_of( Callback::Event::Unified )
        canary[:arg].payload_a.should eql( nil )
      end

      it "1 payload arg - handler gets 1 event object" do
        emitter.emit :bar, 'foo'
        canary[:arg].should be_kind_of( Callback::Event::Unified )
        canary[:arg].payload_a.first.should eql( 'foo' )
      end

      it "2 payload args - handler gets 1 event obj with 2 args arr in p.l" do
        emitter.emit :bar, 'foo', 'baz'
        canary[:arg].should be_kind_of( Callback::Event::Unified )
        canary[:arg].payload_a.should eql( ['foo', 'baz'] )
      end
    end

    context "exactly two arguments, emit" do
      let :emitter do
        o = klass.new
        o.on_bar do |a, b|
          canary[:args] = [a, b]
        end
        o
      end

      it "0 payload args - handler gets 2 nils" do
        emitter.emit :bar
        canary[:args].should eql( [nil, nil] )
      end

      it "1 payload arg - handler gets the 1 arg and 1 nil" do
        emitter.emit :bar, 'foo'
        canary[:args].should eql( ['foo', nil] )
      end

      it "2 payload args - handler gets the two" do
        emitter.emit :bar, 'one', 2
        canary[:args].should eql( ['one', 2] )
      end
    end
  end
end
