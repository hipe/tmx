require_relative '../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  describe "[br] entity - processing the polymorphic upstrem" do

    context "basics" do

      before :all do

        class Foo_Iamb

          Subject_[].call self do

            def foo
              @foo_x = gets_one_polymorphic_value
            end

            def bar
              @bar_x = gets_one_polymorphic_value
            end

          end

          attr_reader :foo_x, :bar_x

          Enhance_for_test_[ self ]
        end
      end

      it "do parse one does work" do
        Foo_Iamb.with( :foo, :FOO ).foo_x.should eql :FOO
      end

      it "do parse two does work" do
        foo = Foo_Iamb.with( :foo, :FOO, :bar, :BAR )
        foo.foo_x.should eql :FOO
        foo.bar_x.should eql :BAR
      end

      it "do parse strange does not work" do

        _be_this_msg = match %r(\Aunrecognized attribute 'wiz')

        begin
          Foo_Iamb.with :wiz
        rescue Home_::Field_::ArgumentError => e
        end

        e.message.should _be_this_msg
      end

      it "do parse none does work" do
        Foo_Iamb.with
      end
    end

    it "DSL syntax fail - strange name" do

      _be_this_msg = match %r(\Aunrecognized property 'VAG_rounded')

      begin
        class FooI_Pity
          Subject_[][ self, :VAG_rounded ]
        end
      rescue Home_::ArgumentError => e
      end

      e.message.should _be_this_msg
    end

    it "DSL syntax fail - strange value" do

      begin
        class FooI_PityVal
          Subject_[][ self, :polymorphic_writer_method_name_suffix ]
        end
      rescue Home_::ArgumentError => e
      end

      e.message.should match %r(\bexpecting a value for 'polymorphic_)
    end

    context "iambic writer postfix option (& introduction to using the DSL)" do

      before :all do
        class FooI_With_Postfix
          attr_reader :x
          Subject_[].call self, :polymorphic_writer_method_name_suffix, :'=' do
            def some_writer=
              @x = gets_one_polymorphic_value
            end
          end
          Enhance_for_test_[ self ]
        end
      end

      it "iambic writer is recognized (and the DSL is used in the '[]')" do
        FooI_With_Postfix.with( :some_writer, :foo ).x.should eql :foo
      end

      it "for now enforces that you use the suffix on every guy" do
        _rx = /\bdid not have expected suffix '_derp': 'ferp'/
        -> do
        class FooI_Bad_Suffixer
          Subject_[].call self, :polymorphic_writer_method_name_suffix, :_derp do
            def ferp
            end
          end
        end
        end.should raise_error ::NameError, _rx
      end
    end
  end
end
