require_relative '../test-support'

module Skylab::Headless::TestSupport::DE__

  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS

  Headless = Headless

  extend TestSupport::Quickie

  describe "[hl] core delegating" do

    context "basic delegation to only one low-stream with 'delegate'" do

      before :all do

        class Basic_Base
          def foo ; :FOO end
          def bar ; :BAR end
        end

        class Basic_Client
          Headless::Delegating[ self ]
          delegate :foo, :bar
          def initialize x
            super
          end
        end
      end

      it "delegate to many methods at once with 'delegate'" do
        cli = Basic_Client.new Basic_Base.new
        cli.foo.should eql :FOO
        cli.bar.should eql :BAR
      end
    end

    context "basic delegation to only one low stream with 'delegating'" do
      before :all do
        class B2_Base
          def bar ; :BAR end
        end
        class B2_Client
          Headless::Delegating[ self ]
          delegating :to_method, :bar, :foo
        end
      end

      it "ok" do
        cli = B2_Client.new B2_Base.new
        cli.foo.should eql :BAR
      end
    end

    context "basic delegation (using iambic arguments)" do

      before :all do

        class B_DSL_Base
          def foo ; :FEW end
          def bar ; :BRER end
        end

        class B_DSL_Client
          Headless::Delegating[ self, %i( foo bar ) ]
        end
      end

      it "works this way too if you pass an array of symbols" do
        cli = B_DSL_Client.new B_DSL_Base.new
        cli.foo.should eql :FEW
        cli.bar.should eql :BRER
      end
    end

    context "delegating with a name change with 'delegate' 'as' (iambic)" do

      before :all do

        class As_Base
          def x_foo_y ; :FREW end
          def biff ; :BRIFF end
          def braff ; :BRAFF end
        end

        class As_Client
          Headless::Delegating[ self, :foo, :with_infix, :x_, :_y,
                                :biff, :as, :bar,
                                :zack, :to_method, :braff ]
        end
      end

      it "ok" do
        cli = As_Client.new As_Base.new
        cli.foo.should eql :FREW
        cli.bar.should eql :BRIFF
        cli.zack.should eql :BRAFF
      end
    end
  end
end
