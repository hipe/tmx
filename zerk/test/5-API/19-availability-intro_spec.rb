require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - availability intro" do

    TS_[ self ]
    use :API

    context "not available" do

      call_by do
        call :flickerer  # #test-05+avail
      end

      it "fails" do
        fails
      end

      it "emits \"operation 'foo' is not available\"" do

        _be_this = be_emission_ending_with :operation_is_not_available do |ev|
          _ = black_and_white ev
          _.should eql "operation 'flickerer' is not available"
        end

        only_emission.should _be_this
      end
    end

    context "available" do

      call_by do

        @root_ACS = build_root_ACS
        @root_ACS.make_flickerer_available_!

        call :flickerer  # #test-05+avail
      end

      it "yay" do
        root_ACS_result.should eql :_yep_
      end

      it "no emissions" do
        expect_no_emissions
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_22_Uggs ]
    end
  end
end
