require_relative 'test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] 3 - x spec" do

    TS_[ self ]
    use :expect_screens

    subject_ACS_class_ do

      TS_.lib_ :examples_example_01_zombies
    end

    context "first screen" do

      input_  # nothing

      it "shows the buttons at the bottom" do

        last_line_.should look_like_a_line_of_buttons_
      end

      it "the button \"hotstrings\" are the shortest they need to be to etc." do

        hotstring_for_( 'biz-nappe' ).should eql 'b'
        hotstring_for_( 'fozzer' ).should eql 'fo'
        hotstring_for_( 'fizzie-nizzie' ).should eql 'fi'
      end
    end

    context "sending an interrupt from first frame" do

      input_ false

      it "exits successfully" do
        exitstatus_.should be_successful_exitstatus_
      end

      it "says goodbye" do
        last_line_.should eql "goodbye."
      end
    end

    context "an unterpretable \"button\" from first frame" do

      input_ 'montauk'

      it "expresses that it wasn't recognized" do

        first_line_.should match_line_for_unrecognized_argument_ 'montauk'
      end

      it "asks \"did you mean?" do

        unstyle_styled_( second_line_ ).should eql(
          "did you mean 'fozzer', 'fizzie-nizzie' or 'biz-nappe'?" )
      end

      it "displays the first screen again" do

        buttons_.should have_button_for_ 'fozzer'
      end

      it "ends at first frame" do

        stack_.should be_at_frame_number_ 1
      end
    end

    context "an ambiguous \"button\" from first frame" do

      input_ 'f'

      it "expresses" do

        first_line_.should eql(
          'ambiguous argument "f" - did you mean "fozzer" or "fizzie-nizzie"?' )
      end

      it "waits at first frame" do

        stack_.should be_at_frame_number_ 1
      end
    end

    context "a good button for a simple field" do

      input_ 'fo'

      it "blocks waiting for input (does not end the line)" do

        last_line_unchomped_.should _be_this_prompt
      end

      it "waits at second frame" do

        stack_.should be_at_frame_number_ 2
      end
    end

    context "good button, then invalid value" do

      input_ 'fo', '/x'

      it "complains of invalid" do

        first_line_.should eql 'paths can\'t be absolute - "/x"'
      end

      it "goes back to the same prompt immediately after" do

        last_line_.should _be_this_prompt
      end
    end

    def _be_this_prompt
      eql "enter fozzer: "
    end

    context "good button then invalid value then cancel" do

      input_ 'fo', '/x', false

      it "leaves you at the first frame" do

        stack_.should be_at_frame_number_ 1
      end
    end

    context "good button, then valid value" do

      input_ 'fo', 'xhi'

      it "first line confirms that it wrote" do
        first_line_.should eql 'set fozzer to "xhi"'
      end

      it "redisplays *all* buttons for first screen" do

        buttons_.should be_in_any_order_the_buttons_(
          'fozzer', 'fizzie-nizzie', 'biz-nappe' )
      end
    end

    def state_  # muscle memory (for manually debugging only..)
      _expscr_session_state
    end
  end
end