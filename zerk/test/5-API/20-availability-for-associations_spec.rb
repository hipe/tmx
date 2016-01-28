require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - availability for associations" do

    TS_[ self ]
    use :API

    context "read when available" do

      call_by do
        call :upper_color  # #test-07
      end

      it "ok" do
        kn = root_ACS_result
        kn.is_known_known and fail
        kn.association.name_symbol.should eql :upper_color
      end
    end

    context "write when available" do

      call_by do
        call :upper_color, :red  # #test-11
      end

      it "ok" do
        _o = root_ACS
        _o.upper_color.should eql :red
      end
    end

    context "read when unavailable" do

      call_by do
        @root_ACS = build_root_ACS
        @root_ACS.make_ucolor_unavailable_!
        call :upper_color  # #test-07+avail
      end

      it "fails" do
        fails
      end

      it "emits" do
        only_emission.should _be_this
      end
    end

    context "write when unavailable" do

      call_by do
        @root_ACS = build_root_ACS
        @root_ACS.make_ucolor_unavailable_!
        call :upper_color, :red  # #test-11+avail
      end

      it "fails" do
        fails
      end

      it "emits" do
        only_emission.should _be_this
      end
    end

    def _be_this
      be_emission_ending_with :association_is_not_available do |ev|
        _ = black_and_white ev
        _.should eql "association 'upper-color' is not available"
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_22_Uggs ]
    end
  end
end
