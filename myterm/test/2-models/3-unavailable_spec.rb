require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] unavailable" do

    TS_[ self ]
    use :my_API

    context "when neither is set" do

      call_by do

        begin
          call :adapter, COMMON_ADAPTER_CONST_,
            :imagemagick_command
        rescue ::ArgumentError => e
        end

        e
      end

      it "raises argument error" do
        root_ACS_state or fail
      end

      it "says which pieces are missing" do

        _s = "can't produce an image without #{
          }\"background font\" and \"label\""

        root_ACS_state.message.should eql _s
      end
    end
  end
end
