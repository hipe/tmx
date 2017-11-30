require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - params intro (DOESN'T EVEN GET TO PARAMS)" do

    TS_[ self ]
    use :my_API

    it "shoe model loads" do
      expect( subject_root_ACS_class.hello ).to eql :_omg_shoes_
    end

    context "call a strange operation - enumerates avail. ops" do

      call_by do
        call :shoe, :wazoozle  # [#test-02 &] #test-50-02
      end

      it "fails" do
        fails
      end

      it "\"did you mean..\" INCLUDES operation name(s)" do

        _be_this = be_emission_ending_with no_such_association_ do |ev|

          _ = black_and_white ev
          expect( _ ).to look_like_did_you_mean_for_ %w( lace globbie_guy globbie_complex )
        end

        expect( only_emission ).to _be_this
      end
    end

    context "an invoke that ends on the branch node that wasn't set.." do

      call_by do
        call :shoe, :lace  # [#test-08 &] #test-50-08
      end

      it "results in a qk talkin bout known unknown" do
        qk = root_ACS_result
        qk.is_known_known and fail
        expect( qk.association.name_symbol ).to eql :lace
      end

      it 'emits nothing' do
        want_no_emissions
      end
    end

    context "call an operation under the sub-branch" do

      call_by do
        call :shoe, :lace, :get_color  # [#test-05 &] #test-50-05
      end

      it "results in whatever business result" do
        _x = root_ACS_result
        expect( _x ).to eql 'white'
      end

      it "emits whatever business emission" do

        _be_this = be_emission :info, :expression, :working do |a|
          expect( a ).to eql [ "retrieving ** color **" ]
        end

        expect( only_emission ).to _be_this
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_21_Another_Shoe ]
    end
  end
end
