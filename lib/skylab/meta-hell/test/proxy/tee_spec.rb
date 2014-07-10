require_relative 'tee/test-support.rb'

module Skylab::MetaHell::TestSupport::Proxy::Tee

  describe "#{ MetaHell_::Proxy::Tee } - a tee" do

    extend Tee_TestSupport

    _klass = -> {  MetaHell::Proxy::Tee }

    define_method :klass, &_klass

    context "tee has a struct-like constructor that produces a class" do

      it "as in ::Struct you can't construct a tee class with no arguments" do
        -> { klass.new }.should raise_error ::ArgumentError, /0 for 1/
      end
    end

    memoize :tee_class, -> do
      Tee_TestSupport.const_set_next( "KLS_", _klass[].new( :push, :pop ))
    end

    let :tee_instance do tee_class.new end

    context "let's construct a tee for the methods `push` and `pop`" do

      context "you can construct the tee with no args" do

        it "if you send it a message it doesn't respond to - it raises #{
          }(with few exceptions)" do

          -> { tee_instance.class }.should raise_error( ::NoMethodError,
            /undefined method `class' for.*Tee::KLS_/
          )
        end

        it "if you send it a message in the list - (no upstreams) result #{
          }is nil" do
          res = tee_instance.push
          res.should eql( nil )
        end
      end
    end

    context "adding dowstream children to the tee (the main thing)" do
      it "is accomplisehd by using []=" do
        a = [] ; b = [] ; tee = tee_instance
        tee[:nerk] = a
        tee[:derk] = b
        res = tee.push 'one'
        res.should eql( ['one'] )
        a.should eql( ['one'] )
        b.should eql( ['one'] )
      end
    end
  end
end
