require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - availability for associations" do

    TS_[ self ]
    use :my_API

    context "read when available" do

      call_by do
        call :upper_color  # #test-07
      end

      it "ok" do
        kn = root_ACS_result
        kn.is_known_known and fail
        expect( kn.association.name_symbol ).to eql :upper_color
      end
    end

    context "write when available" do

      call_by do
        call :upper_color, :red  # #test-11
      end

      it "ok" do
        _o = root_ACS
        expect( _o.upper_color ).to eql :red
      end
    end

    _say_this = 'association "upper-color" is not available'

    context "read when unavailable" do

      call_by do

        @root_ACS = build_root_ACS
        @root_ACS.make_ucolor_unavailable_!

        begin
          call :upper_color  # #test-07+avail
        rescue Home_::ACS_::NotAvailable => e
        end
        e
      end

      it "raises argument error" do
        root_ACS_state or fail
      end

      it "says.." do
        expect( root_ACS_state.message ).to eql _say_this
      end
    end

    context "write when unavailable" do

      call_by do

        @root_ACS = build_root_ACS
        @root_ACS.make_ucolor_unavailable_!

        begin
          call :upper_color, :red  # #test-11+avail
        rescue Home_::ACS_::NotAvailable => e
        end
        e
      end

      it "raises argument error" do
        root_ACS_state or fail
      end

      it "says.." do
        expect( root_ACS_state.message ).to eql _say_this
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_22_Uggs ]
    end
  end
end
