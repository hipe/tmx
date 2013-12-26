require_relative '../test-support'

module Skylab::Headless::TestSupport::Bundles::Delegating

  describe "[hl] bundle: delegating - surface" do

    it "'delegate' lets you delegate simply" do

        class Base_simple_Surface
          def foo ; :FOO end
          def bar ; :BAR end
        end

        class Client_simple_Surface
          Headless::Delegating[ self ]
          delegate :foo, :bar
          def initialize x
            super
          end
        end

        cli = Client_simple_Surface.new Base_simple_Surface.new
        cli.foo.should eql :FOO
        cli.bar.should eql :BAR
    end

    it "'if' adds a conditional to the delegation (nil when falseish)" do

        class Base_if_Surface
          def foo ; :FOO end
          def bizzle x ; "bizzle:(#{ x })" end
        end

        class Client_if_Surface
          Headless::Delegating[ self ]
          delegating :if, -> { is_ready }, :foo,
            :if, -> { is_ready }, :bizzle

          attr_accessor :is_ready
        end

        cli = Client_if_Surface.new Base_if_Surface.new
        cli.foo.should be_nil
        cli.bizzle.should be_nil
        cli.is_ready = true
        cli.foo.should eql :FOO
        cli.bizzle( 'WIZ' ).should eql 'bizzle:(WIZ)'
    end

    it "'to_method' lets you specify a different lowstream method name" do

        class Base_to_method_Surface
          def bar ; :BAR end
        end

        class Client_to_method_Surface
          Headless::Delegating[ self ]
          delegating :to_method, :bar, :foo
        end

        _cli = Client_to_method_Surface.new Base_to_method_Surface.new
        _cli.foo.should eql :BAR
    end

    it "'to_method' doesn't make sense with multiple delegatee methods - X" do

      -> do
        class Client_Not_Multiple_to_method_Surface
          Headless::Delegating[ self ]
          delegating :to_method, :bar, %i( frik frak )
        end
      end.should raise_error ::ArgumentError, /\bcannot delegate #{
        }these to the same method: 'frik', 'frak'/
    end

    it "'to' lets you specify various delegatees - meth if looks like meth" do

        class Base_Purple_to_meth_Suface
          def foo ; :FOO end
        end
        class Base_Green_to_meth_Surface
          def bar ; :BAR end
        end
        class Client_to_meth_Surface
          Headless::Delegating[ self ]
          delegating :to, :purple, %i( foo ),
            :to, :green, %i( bar )
          def initialize
            @ppl = Base_Purple_to_meth_Suface.new
            @grn = Base_Green_to_meth_Surface.new
            super()
          end
        private
          def purple ; @ppl end
          def green ; @grn end
        end

        _cli = Client_to_meth_Surface.new
        _cli.foo.should eql :FOO
        _cli.bar.should eql :BAR
    end

    it "'to' lets you specify various delegatees - ivar if looks like ivar" do

        class Base_Purple_to_ivar_Suface
          def foo ; :FOO end
        end
        class Base_Green_to_ivar_Surface
          def bar ; :BAR end
        end
        class Client_to_ivar_Surface
          Headless::Delegating[ self ]
          delegating :to, :@purple, %i( foo ),
            :to, :@green, %i( bar )

          def initialize
            @purple = Base_Purple_to_ivar_Suface.new
            @green = Base_Green_to_ivar_Surface.new
            super()
          end
        end

        _cli = Client_to_ivar_Surface.new
        _cli.foo.should eql :FOO
        _cli.bar.should eql :BAR
    end

    it "'with_infix' lets you specify a pattern for name translation" do

        class Base_with_infix_Surface
          def resolve_some_foo_for_client ; :FOO end
          def resolve_some_bar_for_client ; :BAR end
        end
        class Client_with_infix_Surface
          Headless::Delegating[ self ]
          delegating :with_infix, :resolve_some_, :_for_client,
            %i( foo bar )
        end

        cli = Client_with_infix_Surface.new Base_with_infix_Surface.new
        cli.foo.should eql :FOO
        cli.bar.should eql :BAR
    end

    it "'with_suffix' lets you specify a pattern for name translation, too" do

        class Base_with_suffix_Surface
          def foo_from_client ; :FOO end
          def bar_from_client ; :BAR end
        end
        class Client_with_suffix_Surface
          Headless::Delegating[ self ]
          delegating :with_suffix, :_from_client, %i( foo bar )
        end

        cli = Client_with_suffix_Surface.new Base_with_suffix_Surface.new
        cli.foo.should eql :FOO
        cli.bar.should eql :BAR
    end
  end
end
