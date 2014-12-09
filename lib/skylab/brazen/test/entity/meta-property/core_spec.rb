require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties" do

    it "(sneak ahead to an essential case)" do

        class MP_Sneak
          Subject_[].call self do
            o :argument_arity, :zero, :meta_property, :requored,
              :requored, :property, :wazoozle,
              :property, :foozle
          end
        end

        _a = MP_Sneak.properties.reduce_by do |prop|
          prop.requored
        end.to_a

        _a.length.should eql 1
        prop = _a.first
        prop.name_i.should eql :wazoozle
    end

    context "create arbitrary meta-properties and use them in the properties" do

      before :all do

        class MP_Foo
          Subject_[].call self do
            o :meta_property, :fun_ness
            o :fun_ness, :really_fun, :property, :foo
          end

          define_singleton_method :with, WITH_MODULE_METHOD_
        end
      end

      it "still works as a property ofc" do
        expect_works_as_property MP_Foo
      end

      it "reflect with your meta-properties" do
        expect_reflects MP_Foo
      end
    end

    context "if your iambic writer is defined classically, works the same" do

      before :all do

        class MP_Bar
          Subject_[].call self do
            o :meta_property, :fun_ness
            o :fun_ness, :really_fun
            def foo
              @foo = iambic_property
            end
          end

          define_singleton_method :with, WITH_MODULE_METHOD_
        end
      end

      it "works as prop" do
        expect_works_as_property MP_Bar
      end

      it "reflects" do
        expect_reflects MP_Bar
      end
    end

    def expect_works_as_property cls
      foo = cls.with :foo, :bar
      foo.instance_variable_get( :@foo ).should eql :bar
    end

    def expect_reflects cls
      cls.properties[ :foo ].fun_ness.should eql :really_fun
    end
  end
end
