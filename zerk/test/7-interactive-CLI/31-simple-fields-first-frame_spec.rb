require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - simple fields first frame" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_screens

    shared_subject :subject_CLI do
      # #todo - think about pushing this up to `expect_screens` maybe?

      _ACS_class = subject_root_ACS_class

      cli = Home_::Interactive_CLI.begin

      cli.root_ACS = -> & top_oes_p do
        _ACS_class.new( & top_oes_p )
      end

      cli.to_classesque
    end

    def stdout_is_expected_to_be_written_to
      false
    end

    context "first screen" do

      given do
        input  # nothing
      end

      it "shows the buttons at the bottom" do

        last_line.should look_like_a_line_of_buttons_
      end

      it "the button \"hotstrings\" are the shortest they need to be to etc." do

        hotstring_for_( 'biz-nappe' ).should eql 'b'
        hotstring_for_( 'fozzer' ).should eql 'fo'
        hotstring_for_( 'fizzie-nizzie' ).should eql 'fi'
      end
    end

    context "sending an interrupt from first frame" do

      given do
        input false
      end

      it "exits successfully" do
        exitstatus_.should be_successful_exitstatus_
      end

      it "says goodbye" do
        last_line.should eql "goodbye."
      end
    end

    context "an unterpretable \"button\" from first frame" do

      given do
        input 'montauk'
      end

      it "expresses that it wasn't recognized" do

        first_line.should match_line_for_unrecognized_argument_ 'montauk'
      end

      it "asks \"did you mean?\"" do

        unstyle_styled_( second_line ).should eql(
          "did you mean 'fozzer', 'fizzie-nizzie' or 'biz-nappe'?" )
      end

      it "displays the first screen again" do

        buttonesques.should have_button_for 'fozzer'
      end

      it "ends at first frame" do

        stack.should be_at_frame_number 1
      end
    end

    context "an ambiguous \"button\" from first frame" do

      given do
        input 'f'
      end

      it "expresses" do

        first_line.should eql(
          'ambiguous argument "f" - did you mean "fozzer" or "fizzie-nizzie"?' )
      end

      it "waits at first frame" do

        stack.should be_at_frame_number 1
      end
    end

    context "a good button for a simple field" do

      given do
        input 'fo'
      end

      it "blocks waiting for input (does not end the line)" do

        last_line_not_chomped_.should _be_this_prompt
      end

      it "waits at second frame" do

        stack.should be_at_frame_number 2
      end
    end

    context "good button, then invalid value" do

      given do
        input 'fo', 'ZYXwv'
      end

      it "complains of invalid" do

        first_line.should eql 'string must be in all caps (had: "w")'
      end

      it "goes back to the same prompt immediately after" do

        last_line.should _be_this_prompt
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

        stack.should be_at_frame_number 1
      end
    end

    context "good button, then valid value" do

      given do
        input 'fo', 'YXW'
      end

      it "first line confirms that it wrote" do

        first_line.should eql 'set fozzer to "YXW"'
      end

      it "redisplays *all* buttons for first screen" do

        buttonesques.should be_in_any_order_the_buttons_(
          'fozzer', 'fizzie-nizzie', 'biz-nappe' )
      end
    end

    def root_ACS_state  # muscle memory (for manually debugging only..)
      _expscr_session_state
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_31_3_Prims_and_a_Transtive_Operation ]
    end
  end
end
