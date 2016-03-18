require_relative '../../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_stack_common_frame
  module Attributes::Stack::Common_Frame

    TS_.describe "[br] property - stack - common frame - integrate with entity" do

      Here_[ self ]

    before :all do

      class X_IE_A

        Subject_.call self,
          :globbing, :processor, :initialize,
          :readable, :field, :foo,
          :required, :readable, :field, :bar

        Home_.lib_.brazen::Entity.call self do
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
      X_IE_A.properties.get_names.should eql [ :foo, :bar, :biz ]
    end

    it "required fields still bork" do
      _rx = /\Amissing required field - 'bar'/
      -> do
        X_IE_A.new
      end.should raise_error ::ArgumentError, _rx
    end

    it "works with all" do
      foo = X_IE_A.new :biz, :B, :foo, :F, :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql %i| F A B |
    end

    it "works with one" do
      foo = X_IE_A.new :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql [ nil, :A, nil ]
    end
    end
  end
end
