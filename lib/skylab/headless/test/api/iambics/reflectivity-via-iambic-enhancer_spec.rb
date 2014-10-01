require_relative 'test-support'

module Skylab::Headless::TestSupport::API::Iambics

  describe "[hl] API iambics - reflectivity via iambic enhancer" do

    context "monadic two" do

      before :all do
        class Two_VIE
          Headless_::API::Iambic_parameters[ self, :params,
            :one, :two ]

          def initialize * x_a
            nilify_and_absorb_iambic_fully x_a
            super()
          end

          attr_reader :one, :two
        end
      end

      it "loads" do
      end

      it "reflects" do
        Two_VIE.get_parameter_box._a.should eql %i( one two )
      end

      it "works (inside)" do
        v = Two_VIE.new :two, :Two
        v.one.should be_nil
        v.two.should eql :Two
      end

      it "outside - X" do
        -> do
          Two_VIE.new :one, :One, :uh_oh, :_no_see_
        end.should raise_error ::ArgumentError,
          /\bunexpected iambic term 'uh_oh'/
      end
    end
  end
end
