require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Fields_::ICAF_

  ::Skylab::MetaHell::TestSupport::FUN::Fields_[ TS_ = self ]

  include CONSTANTS

  MetaHell = MetaHell

  describe "#{ MetaHell }::FUN::Fields_ integrate contoured and from" do

    before :all do

      class Foo

        MetaHell::FUN::Fields_::Contoured_[ self,
          :field, :foo,
          :required, :field, :bar ]

      private
        MetaHell::FUN::Fields_::From_.methods do
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
