require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] unavailable" do

    TS_[ self ]
    use :my_API

    context "when neither is set" do

      call_by do
        call :adapter, COMMON_ADAPTER_CONST_,
          :imagemagick_command
      end

      it "fails" do
        fails
      end

      it "emits explaining the missing pieces!" do

        _be_this = be_emission_ending_with :remaining_required_fields do |y|
          y.should eql([
            "(still needed before we can produce an image: #{
              }\"background font\" and \"label\")"])
        end

        last_emission.should _be_this
      end
    end
  end
end
