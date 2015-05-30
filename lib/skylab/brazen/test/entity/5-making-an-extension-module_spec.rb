require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity extending" do

    context "empty definition block" do

      before :all do
        _ = Subject_[]
        FooE_Mod = _.call do
        end
      end

      it "with one argument (a proc), subject creates a new module" do
        FooE_Mod.should be_respond_to :constants
      end
    end

    context "definition block with two properties" do

      before :all do

        FooE_Two = Subject_[].call do

          def foo
            @foo_x = gets_one_polymorphic_value
            true
          end

          def bar
            @bar_x = gets_one_polymorphic_value
            true
          end

          module self::Module_Methods
            define_method :with, WITH_MODULE_METHOD_
          end

          include Test_Instance_Methods_
        end

        module FooE_Two
          attr_reader :foo_x, :bar_x
        end

        class FooE_Two_Child

          FooE_Two.call self do

            def bar
              @has_bar = true
              super
            end

            def baz
              @baz_x = gets_one_polymorphic_value
              true
            end
          end

          attr_reader :has_bar, :baz_x
        end
      end

      it "extension module both gives properties and allows new to be added" do
        foo = FooE_Two_Child.with :foo, :F, :bar, :B, :baz, :Z
        foo.has_bar.should eql true
        foo.foo_x.should eql :F
        foo.bar_x.should eql :B
        foo.baz_x.should eql :Z
      end
    end

    context "just extension with no extra" do

      before :all do

        FooE_Props = Subject_[].call do

          def uh
            @uh_x = gets_one_polymorphic_value
            true
          end

          def ah
            @ah_x = gets_one_polymorphic_value
            true
          end

          module self::Module_Methods
            define_method :with, WITH_MODULE_METHOD_
          end

          include Test_Instance_Methods_

        end

        class FooE_Prop_Wanter
          FooE_Props[ self ]
          attr_reader :uh_x, :ah_x
        end
      end

      it "ok" do
        foo = FooE_Prop_Wanter.with :uh, :U, :ah, :A
        foo.uh_x.should eql :U
        foo.ah_x.should eql :A
      end
    end

    context "diamond" do

      before :all do

        FooE_Left = Subject_[].call do

          def one
            @one_x = gets_one_polymorphic_value
            true
          end

          def two
            @one_x = gets_one_polymorphic_value
            true
          end
        end

        FooE_Right = Subject_[].call do

          def two
            @two_x = gets_one_polymorphic_value.to_s.upcase.intern
            true
          end

          def three
            @three_x = gets_one_polymorphic_value
            true
          end
        end

        class FooE_Mid
          FooE_Left[ self ]
          FooE_Right[ self ]
          attr_reader :one_x, :two_x, :three_x
          Enhance_for_test_[ self ]
        end
      end

      it "ok - overriding is order dependant" do
        foo = FooE_Mid.with :one, :_one_, :two, :_two_, :three, :_three_
        foo.one_x.should eql :_one_
        foo.two_x.should eql :_TWO_
        foo.three_x.should eql :_three_
      end
    end
  end
end