require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity::Properties_Stack__::Common_Frame__::IWE

  ::Skylab::Brazen::TestSupport::Entity::Properties_Stack__::Common_Frame__[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Brazen_ = Brazen_ ; Subject_ = Subject_

  describe "[br] properties stack common frame - integrate with entity" do

    before :all do

      class Foo

        Subject_.call self,
          :globbing, :processor, :initialize,
          :readable, :field, :foo,
          :required, :readable, :field, :bar

        Brazen_::Entity.call self, -> do
          def biz
            @biz_x = iambic_property
          end
        end

        attr_reader :biz_x
      end
    end

    it "loads" do
    end

    it "property names look good" do
      Foo.properties.get_names.should eql [ :foo, :bar, :biz ]
    end

    it "required fields still bork" do
      -> do
        Foo.new
      end.should raise_error ::ArgumentError,
        /\Amissing required field - 'bar'/
    end

    it "works with all" do
      foo = Foo.new :biz, :B, :foo, :F, :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql %i| F A B |
    end

    it "works with one" do
      foo = Foo.new :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql [ nil, :A, nil ]
    end
  end
end
