require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] stack - common frame - integrate with pstack" do

    before :all do

      class X_cf_IntWithStack_1

        TS_::Common_Frame.lib.call self,

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
      frame = X_cf_IntWithStack_1.new {}
      stack = Home_::Stack.new
      stack.push_frame frame
      stack.push_frame_with :foo, :FOO
      stack.dereference( :foo ) == :FOO || fail
      stack.dereference( :bar ) == 1 || fail
      stack.dereference( :bar ) == 1 || fail

      stack.dereference( :baz ) == 'baz.' || fail
      stack.dereference( :boffo ) == "Foo: 1" || fail
    end
  end
end
