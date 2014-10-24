require_relative 'test-support'

module Skylab::Callback::TestSupport::Proxy

  describe "[cb] proxy - functional" do

    context "one." do

      before :all do
        Pxy::One = Subject_[].functional :foo, :bar
      end

      it "makes" do
      end

      it "build a proxy from proxy class with a hash" do

        pxy = Pxy::One.new foo: -> x { "#{ pee }-#{ x }-#{ dee }" },
                           bar: -> { @dee_meyers }
        @dee_meyers = 'who'

        pxy.foo( 'y' ).should eql 'wee-y-who'
        pxy.bar.should eql 'who'
      end

      it "build it from a literal iambic" do
        pxy = Pxy::One.new :foo, -> { :A }, :bar, -> { @b }
        @b = :B
        pxy.foo.should eql :A
        pxy.bar.should eql :B
      end

      def pee
        'wee'
      end

      def dee
        @dee_meyers
      end

    end

    context "two." do

      before :all do
        Pxy::Two = Subject_[].functional :zerpie, :derkie, :tata do
          def hi
            :"__#{ hello }__"
          end
        end

        class Pxy::Two
          def hello
            :hej
          end
        end
      end

      it "raises key error on extra" do
        _rx = /\Akey not found: :murphy/
        -> do
          Pxy::Two.new :murphy, :bed
        end.should raise_error ::KeyError, _rx
      end

      it "raises argument error on missing" do
        _rx = /\Amissing required proxy function definition\(s\): \(derkie, tata\)\z/
        -> do
          Pxy::Two.new zerpie: :herpie
        end.should raise_error ::ArgumentError, _rx
      end

      it "you can add more stuff in an arbitrary definition block" do
        pxy = Pxy::Two.new :zerpie, nil, :derkie, nil, :tata, nil
        pxy.hi.should eql :__hej__
      end
    end

    Pxy = ::Module.new
  end
end
