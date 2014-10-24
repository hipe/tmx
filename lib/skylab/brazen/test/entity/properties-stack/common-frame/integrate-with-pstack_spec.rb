require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity::Properties_Stack__::Common_Frame__::IWP

  ::Skylab::Brazen::TestSupport::Entity::Properties_Stack__::Common_Frame__[ self ]

  include Constants

  extend TestSupport_::Quickie

  Brazen_ = Brazen_ ; Subject_ = Subject_

  describe "[br] properties stack common frame - integrate with pstack" do

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
      frame = Base_Frame.new
      stack = Brazen_.properties_stack.new
      stack.push_frame frame
      stack.push_frame_with :foo, :FOO
      stack.property_value( :foo ).should eql :FOO
      stack.property_value( :bar ).should eql 1
      stack.property_value( :bar ).should eql 1
      stack.property_value( :boffo ).should eql "Foo: 1"
    end
  end
end
