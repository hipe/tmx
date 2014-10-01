require_relative '../test-support'

module Skylab::Headless::TestSupport::Bundles::Delegating

  describe "[hl] bundle: delegating - deep" do

    it "delegate simply by passing an array of symbols as the second arg" do

        class Base_Simple_Deep
          def foo ; :FEW end
          def bar ; :BRER end
        end

        class Client_Simple_Deep
          Headless_::Delegating[ self, %i( foo bar ) ]
          def initialize x
            @up_p = -> { x }  # do this yourself
          end
        end

        cli = Client_Simple_Deep.new Base_Simple_Deep.new
        cli.foo.should eql :FEW
        cli.bar.should eql :BRER
    end

    it "'to_method', 'with_infix'" do

        class Base_As_Deep
          def braff ; :BRAFF end
          def x_foo_y ; :FREW end
        end

        class Client_As_Deep
          Headless_::Delegating[ self,
                                :to_method, :braff, :zack,
                                :with_infix, :x_, :_y, :foo ]

          def initialize x
            @up_p = -> { x }
          end
        end

        cli = Client_As_Deep.new Base_As_Deep.new
        cli.foo.should eql :FREW
        cli.zack.should eql :BRAFF
    end
  end
end
