require_relative 'test-support'

module Skylab::Headless::TestSupport::API::Iambics

  describe "[hl] API iambics - box and inheritence" do

    context "load one class" do
      before :all do
        class Load_Me_DSL
          DSL[][ self, * DSL_method_name, :paramitos ]
        end
      end
      it "loads", o:true do
      end
    end

    context "load a class and define a thing" do
      before :all do
        class Define_A_Thing_DSL
          DSL[][ self, * DSL_method_name, :permermerters ]
          permermerters :ziff, :davis
        end
      end

      it "loads" do
      end
    end

    context "cannot re-open definition" do
      it "like so" do
        -> do
          class Cannot_Reopen_DSL
            DSL[][ self, * DSL_method_name, :xx ]
            xx :one
            xx :two
          end
        end.should raise_error ::RuntimeError,
          /\bparameters edit session is write-once\b.+\bcannot re-open\b.+#{
            }\bCannot_Reopen_DSL\b/
      end
    end

    context "across boundaries of inheritence" do

      before :all do
        class Across_Boundaries_Base_DSL
          DSL[][ self, * DSL_method_name, :waffelbee ]
          waffelbee :one, :three
        end

        class Across_Boundaries_Child_DSL < Across_Boundaries_Base_DSL
          waffelbee :two
        end
      end

      it "the child picks up the parent's params (note the order)" do
        bx = Across_Boundaries_Child_DSL.get_waffelbee_box
        bx._a.should eql %i( one three two )
      end

      it "the child gets the selfsame parameter objects as parent" do
        bx = Across_Boundaries_Base_DSL.get_waffelbee_box
        bx_ = Across_Boundaries_Child_DSL.get_waffelbee_box
        one = bx[ :one ] or fail
        one_ = bx_[ :one ] or fail
        one.object_id.should eql one_.object_id
        bx[ :two ] and fail
        bx_[ :two ] or fail
      end
    end
  end
end
