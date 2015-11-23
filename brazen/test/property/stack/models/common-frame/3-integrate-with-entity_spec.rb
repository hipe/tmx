require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport::PropertyStack_Namespace_3____

  ::Skylab::Brazen::TestSupport.lib_(
    :property_stack_models_common_frame
  ).prepare_sandbox self

  describe "[br] property - stack - common frame - integrate with entity" do

    before :all do

      class Foo

        Subject_.call self,
          :globbing, :processor, :initialize,
          :readable, :field, :foo,
          :required, :readable, :field, :bar

        Home_::Entity.call self do
          def biz
            @biz_x = gets_one_polymorphic_value
            true
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
      _rx = /\Amissing required field - 'bar'/
      -> do
        Foo.new
      end.should raise_error ::ArgumentError, _rx
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
