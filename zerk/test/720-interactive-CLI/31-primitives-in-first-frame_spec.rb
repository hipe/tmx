require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - simple fields first frame" do

    TS_[ self ]
    use :memoizer_methods
    use :want_screens

    context "first screen" do

      given do
        input  # nothing
      end

      it "shows the buttons at the bottom" do

        expect( last_line ).to look_like_a_line_of_buttons_
      end

      it "the button \"hotstrings\" are the shortest they need to be to etc." do

        expect( hotstring_for 'biz-nappe' ).to eql 'b'
        expect( hotstring_for 'fozzer' ).to eql 'fo'
        expect( hotstring_for 'fizzie-nizzie' ).to eql 'fi'
      end
    end

    context "sending an interrupt from first frame" do

      given do
        input false
      end

      it "exits successfully" do
        expect( exitstatus_ ).to be_successful_exitstatus_
      end

      it "says goodbye" do
        expect( last_line ).to eql "goodbye."
      end
    end

    context "an uninterpretable \"button\" from first frame" do

      given do
        input 'montauk'
      end

      it "expresses that it wasn't recognized" do

        expect( first_line ).to match_line_for_unrecognized_argument_ 'montauk'
      end

      it "asks \"did you mean?\"" do

        expect( second_line ).to eql(
          %(did you mean "fozzer", "fizzie-nizzie" or "biz-nappe"?) )
      end

      it "displays the first screen again" do

        expect( buttonesques ).to have_button_for 'fozzer'
      end

      it "ends at first frame" do

        expect( stack ).to be_at_frame_number 1
      end
    end

    context "an ambiguous \"button\" from first frame" do

      given do
        input 'f'
      end

      it "expresses" do

        expect( first_line ).to eql(
          'ambiguous argument "f" - did you mean "fozzer" or "fizzie-nizzie"?' )
      end

      it "waits at first frame" do

        expect( stack ).to be_at_frame_number 1
      end
    end

    context "a good button for a simple field" do

      given do
        input 'fo'
      end

      it "blocks waiting for input (does not end the line)" do

        expect( last_line_not_chomped_ ).to _be_this_prompt
      end

      it "waits at second frame" do

        expect( stack ).to be_at_frame_number 2
      end
    end

    context "good button, then invalid value" do

      given do
        input 'fo', 'ZYXwv'
      end

      it "complains of invalid" do

        expect( first_line ).to eql 'string must be in all caps (had: "w")'
      end

      it "goes back to the same prompt immediately after" do

        expect( last_line ).to _be_this_prompt
      end
    end

    def _be_this_prompt
      eql "enter fozzer: "
    end

    context "good button then invalid value then cancel" do

      given do
        input 'fo', 'ZYXab', false
      end

      it "leaves you at the first frame" do

        expect( stack ).to be_at_frame_number 1
      end
    end

    context "good button, then valid value" do

      given do
        input 'fo', 'YXW'
      end

      it "first line confirms that it wrote" do

        expect( first_line ).to eql 'set fozzer to "YXW"'
      end

      it "redisplays *all* buttons for first screen" do

        expect( buttonesques ).to be_in_any_order_the_buttons_(
          'fozzer', 'fizzie-nizzie', 'biz-nappe' )
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_31_Some_Primitivesques ]
    end
  end
end
