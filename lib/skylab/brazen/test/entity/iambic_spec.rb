require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity iambic" do

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
        end.should raise_error ::ArgumentError, unrec_rx( :wiz )
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

    it "DSL syntax fail - strange name" do
      -> do
        class FooI_Pity
          Subject_[][ self, :VAG_rounded ]
        end
      end.should raise_error ::ArgumentError, unrec_rx( :VAG_rounded )
    end

    it "DSL syntax fail - strange value" do
      -> do
        class FooI_PityVal
          Subject_[][ self, :iambic_writer_method_name_suffix ]
        end
      end.should raise_error ::ArgumentError,
        /\bexpecting a value for 'iambic_/
    end

    context "iambic writer postfix option (& introduction to using the DSL)" do

      before :all do
        class FooI_With_Postfix
          attr_reader :x
          Subject_[][ self, :iambic_writer_method_name_suffix, :'=', -> do
            def some_writer=
              @x = iambic_property
            end
          end ]
          define_singleton_method :with, WITH_CLASS_METHOD_
        end
      end

      it "iambic writer is recognized (and the DSL is used in the '[]')" do
        FooI_With_Postfix.with( :some_writer, :foo ).x.should eql :foo
      end

      it "for now enforces that you use the suffix on every guy" do
        -> do
        class FooI_Bad_Suffixer
          Subject_[][ self, :iambic_writer_method_name_suffix, :_derp, -> do
            def ferp
            end
          end ]
        end
        end.should raise_error ::NameError,
          /\bdid not have expected suffix '_derp': 'ferp'/
      end
    end

    def unrec_rx x
      /\bunrecognized property '#{ ::Regexp.escape( x.to_s ) }'/
    end
  end
end
