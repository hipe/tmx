require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity- iambic" do

    context "basics" do

      before :all do

        class Foo_Iamb
          Subject_[][ self, -> do

          def foo
            @foo_x = iambic_property
          end

          def bar
            @bar_x = iambic_property
          end

          end ]
          attr_reader :foo_x, :bar_x

          public :process_iambic_fully
        end
      end

      it "do parse one does work" do
        Foo_Iamb.new.process_iambic_fully( [ :foo, :FOO ] ).foo_x.should eql :FOO
      end

      it "do parse two does work" do
        foo = Foo_Iamb.new
        foo.process_iambic_fully( [ :foo, :FOO, :bar, :BAR ] )
        foo.foo_x.should eql :FOO
        foo.bar_x.should eql :BAR
      end

      it "do parse strange does not work" do
        -> do
          Foo_Iamb.new.process_iambic_fully( [ :wiz ] )
        end.should raise_error ::ArgumentError,
          /\bunrecognized property 'wiz'/
      end

      it "parse is non-destructive" do
        a = [ :foo, :x ]
        Foo_Iamb.new.process_iambic_fully a
        a.length.should eql 2
      end

      it "do parse none does work" do
        Foo_Iamb.new.process_iambic_fully [].freeze
      end
    end
  end
end
