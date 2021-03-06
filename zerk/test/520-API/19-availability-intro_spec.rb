require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - availability intro" do

    TS_[ self ]
    use :my_API

    context "not available" do

      call_by do

        begin
          call :flickerer  # #test-05+avail
        rescue Home_::ACS_::NotAvailable => e
        end

        e
      end

      it "raises argument error" do
        root_ACS_state or fail
      end

      it "says.." do

        _s = 'operation "flickerer" is not available'

        expect( root_ACS_state.message ).to eql _s
      end
    end

    context "missing required (proc-based)" do  # this is #here-2

      call_by do

        begin
          call :left_number, '-2', :add  # #test-03
        rescue Home_::ACS_::MissingRequiredParameters => e
        end
        e
      end

      it "raises argument error" do
        root_ACS_state or fail
      end

      it "says.." do

        _s = "'add' is missing required parameter 'right-number'."
        expect( root_ACS_state.message ).to eql _s
      end

      def subject_root_ACS_class
        My_fixture_top_ACS_class[ :Class_11_Minimal_Postfix ]
      end
    end

    context "available" do

      call_by do

        @root_ACS = build_root_ACS
        @root_ACS.make_flickerer_available_!

        call :flickerer  # #test-05+avail
      end

      it "yay" do
        expect( root_ACS_result ).to eql :_yep_
      end

      it "no emissions" do
        want_no_emissions
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_22_Uggs ]
    end
  end
end
