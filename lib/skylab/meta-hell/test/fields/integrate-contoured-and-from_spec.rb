require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Fields::ICAF_

  ::Skylab::MetaHell::TestSupport::Fields[ TS_ = self ]

  include CONSTANTS

  MetaHell = MetaHell

  describe "[mh] FUN::Fields integrate contoured and from" do

    before :all do

      class Foo

        MetaHell::Fields.contoured[ self,
          :overriding, :absorber, :initialize,
          :field, :foo,
          :required, :field, :bar ]

      private
        MetaHell::Fields::From.methods :argful do
          def biz a
            @biz_x = a.shift
          end
        end
       public

        attr_reader :biz_x

      end
    end

    it "field names look good" do
      Foo::FIELDS_._a.should eql( [ :foo, :bar, :biz ] )
    end

    it "required fields still bork" do
      -> do
        Foo.new
      end.should raise_error( ::ArgumentError, /missing required argument - bar/ )
    end

    it "works with all" do
      foo = Foo.new :biz, :B, :foo, :F, :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql( %i| F A B | )
    end

    it "works with one" do
      foo = Foo.new :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql( [ nil, :A, nil ] )
    end
  end
end
