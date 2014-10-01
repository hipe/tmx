require_relative '../test-support'

module Skylab::Headless::TestSupport::CS__

  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  describe "[hl] core client services" do

    context "compound" do

      class Red
        def r1 ; :r_one end
        def r2 ; :r_two end
      end
      RED = Red.new

      class Blue
        def b1_from_guy ; :b_one end
      end
      BLUE = Blue.new

      before :all do
        Client_Svcs = Headless_::Client_Services.new :red, :blue do
          delegating :to, :@red, %i( r1 r2 )
          delegating :to, :@blue, :with_suffix, :_from_guy, %i( b1 )
        end
      end

      it "o" do
        svcs = Client_Svcs.new RED, BLUE
        svcs.r1.should eql :r_one
        svcs.r2.should eql :r_two
        svcs.b1.should eql :b_one
      end

      it "x" do
        expect_argument_error_ish do
          Client_Svcs.new
        end
      end

      it "x" do
        expect_argument_error_ish do
          Client_Svcs.new :x
        end
      end

      it "x" do
        expect_argument_error_ish do
          Client_Svcs.new :a, :b, :c
        end
      end

      def expect_argument_error_ish &p
        p.should raise_error ::IndexError
      end
    end
  end
end
