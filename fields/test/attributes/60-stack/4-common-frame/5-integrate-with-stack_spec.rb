require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport::PropertyStack_Namespace_2____

  ::Skylab::Brazen::TestSupport.lib_(
    :property_stack_models_common_frame
  ).prepare_sandbox self

  describe "[br] property - stack - common frame - integrate with pstack" do

    before :all do

      class Base_Frame

        Subject_.call self,

          :proc, :foo, -> do
            :Foo
          end,

          :memoized, :proc, :bar, -> do
            d = 0
            -> do
              d += 1
            end
          end.call,

          :method, :bif,

          :inline_method, :baz, -> do
            "baz."
          end,

          :memoized, :inline_method, :boffo, -> do
            d = 0
            -> do
              "#{ foo }: #{ d += 1 }"
            end
          end.call
      end
    end

    it "loads" do
    end

    it "ok" do
      frame = Base_Frame.new {}
      stack = Home_::Property::Stack.new
      stack.push_frame frame
      stack.push_frame_with :foo, :FOO
      stack.property_value_via_symbol( :foo ).should eql :FOO
      stack.property_value_via_symbol( :bar ).should eql 1
      stack.property_value_via_symbol( :bar ).should eql 1

      stack.property_value_via_symbol( :baz ).should eql 'baz.'
      stack.property_value_via_symbol( :boffo ).should eql "Foo: 1"
    end
  end
end
