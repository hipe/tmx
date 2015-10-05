require_relative '../../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - makers - functional" do

    extend TS_

    context "one." do

      it "makes" do
        _class
      end

      it "build a proxy from proxy class with a hash" do

        pxy = _class.new foo: -> x { "#{ pee }-#{ x }-#{ dee }" },
                           bar: -> { @dee_meyers }
        @dee_meyers = 'who'

        pxy.foo( 'y' ).should eql 'wee-y-who'
        pxy.bar.should eql 'who'
      end

      it "build it from a literal iambic" do
        pxy = _class.new :foo, -> { :A }, :bar, -> { @b }
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

      dangerous_memoize_ :_class do
        Pxy_Fnctnl_01_01 = _subject :foo, :bar
      end
    end

    context "two." do

      it "raises key error on extra" do
        _rx = /\Akey not found: :murphy/
        -> do
          _class.new :murphy, :bed
        end.should raise_error ::KeyError, _rx
      end

      it "raises argument error on missing" do
        _rx = /\Amissing required proxy function definition\(s\): \(derkie, tata\)\z/
        -> do
          _class.new zerpie: :herpie
        end.should raise_error ::ArgumentError, _rx
      end

      it "you can add more stuff in an arbitrary definition block" do
        pxy = _class.new :zerpie, nil, :derkie, nil, :tata, nil
        pxy.hi.should eql :__hej__
      end

      dangerous_memoize_ :_class do

        Pxy_Fnctnl_01_02 = _subject :zerpie, :derkie, :tata do
          def hi
            :"__#{ hello }__"
          end
        end

        class Pxy_Fnctnl_01_02
          def hello
            :hej
          end
          self
        end
      end
    end

    def _subject * sym_a, & edit_p

      Home_::Proxy::Makers::Functional.new( * sym_a, & edit_p )
    end
  end
end
