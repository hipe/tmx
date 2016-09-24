require_relative '../../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - makers - functional" do

    extend TS_
    use :memoizer_methods

    context "make a 'fuctional' proxy class with a list of member names" do

      before :all do
        X_p_m_f_c_MyProxy = Home_::Proxy::Makers::Functional.new :foo, :bar
      end

      shared_subject :pxy do

        pxy = X_p_m_f_c_MyProxy.new(
          :foo, -> x { "bar: #{ x }" },
          :bar, -> { :BAZ },
        )

        pxy
      end

      it "per the procs you passed, it can take arguments" do
        pxy.foo( :wee ).should eql "bar: wee"
      end

      it "or not" do
        pxy.bar.should eql :BAZ
      end

      shared_subject :pxy2 do

        pxy2 = X_p_m_f_c_MyProxy.new(
          foo: -> { :A },
          bar: -> s { "#{ s.upcase }A#{ s.upcase }" },
        )

        pxy2
      end

      it "note the signatures of the methods have changed" do
        pxy2.foo.should eql :A
        ( pxy2.bar 'y' ).should eql "YAY"
      end
    end

    context "(errors that can happen)" do

      it "raises key error on extra" do

        _rx = /\Akey not found: :murphy/

        begin
          _class.new :murphy, :bed
        rescue ::KeyError => e
        end

        e.message =~ _rx || fail
      end

      it "raises argument error on missing" do

        _rx = /\Amissing required proxy function definition\(s\): \(derkie, tata\)\z/

        begin
          _class.new zerpie: :herpie
        rescue ::ArgumentError => e
        end

        e.message =~ _rx || fail
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
