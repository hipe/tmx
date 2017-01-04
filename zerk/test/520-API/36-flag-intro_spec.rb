require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - flag" do

    TS_[ self ]
    use :my_API

    context "dry run is off is off - not special" do

      call_by do
        call :money
      end

      it "money" do
        _ = root_ACS_result
        _ == false or fail
      end
    end

    context "dry run is on is on - not special" do

      call_by do
        call :probe_lauf, :hi, :money
      end

      it "money" do
        _ = root_ACS_result
        _ == :hi or fail
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_36_Flag ]
    end
  end
end
