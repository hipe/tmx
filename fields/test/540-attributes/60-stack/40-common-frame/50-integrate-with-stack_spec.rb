require_relative '../../../test-support'

module Skylab::Fields::TestSupport

  describe "[br] property - stack - common frame - integrate with pstack" do

    before :all do

      class X_a_s_cf_IntWithStack_1

        Home_::Attributes::Stack::CommonFrame.call self,

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
      frame = X_a_s_cf_IntWithStack_1.new {}
      stack = Home_::Attributes::Stack.new
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
