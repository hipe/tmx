require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - dep graph intro" do

    TS_[ self ]
    use :API

    context "(exposition) try to get a card without money" do

      call_by do
        rescue_argument_error_ do
          call :get_card
        end
      end

      it "raises argument error" do
        raises_argument_error_
      end

      it "message" do
        message_.should eql "'get-card' is missing required parameter 'money'."
      end
    end

    context "(exposition) [..] with invalid money - soft fails" do

      call_by do
        call :money, 'not money', :get_card
      end

      it "fails" do
        fails
      end

      it "expresses" do

        _this_message = "didn't look like a simple number (had: \"not money\")"

        _be_this_emission = be_emission_ending_with :invalid_number do |y|
          _this_message == y.first or fail
        end

        only_emission.should _be_this_emission
      end
    end

    context "(exposition) [..] with valid money, but not enough" do

      call_by do
        call :money, '4', :get_card
      end

      it "fails" do
        fails
      end

      it "emits" do

        _be_this_emission = be_emission_ending_with :insufficient_funds do |y|

          "insufficient funds: need 5 had 4" == y.fetch( 0 ) or fail
        end

        last_emission.should _be_this_emission
      end
    end

    context "(exposition) [..] with enough money" do

      call_by do
        call :money, '5', :get_card
      end

      it "works (result is result)" do
        :_subway_card_ == root_ACS_result or fail
      end

      it "(emits)" do
        only_emission.should be_emission_ending_with :set_leaf_component
      end
    end

    context "unmet dependency one level deep - argument error has two lines" do

      shared_subject :_lines do

        _argument_error_lines do
          call :take_subway
        end
      end

      it "two lines" do
        2 == _lines.length or fail
      end

      it "first line" do
        _first_line == "to 'take-subway', must 'get-card'\n" or fail
      end

      it "second line (note no trailing newline)" do
        _second_line == "'get-card' is missing required parameter 'money'." or fail
      end
    end

    context "failure (of an operation) one step removed - still raises" do

      shared_subject :_lines do

        _argument_error_lines do
          call :money, "4", :take_subway
        end
      end

      it "first line - synopsis" do
        _first_line == "to 'take-subway', must 'get-card'\n" or fail
      end

      it "second line is messaging from the ad-hoc expression" do
        _second_line == "insufficient funds: need 5 had 4." or fail
      end
    end

    context "unmet dependency several levels deep" do

      shared_subject :_lines do

        _argument_error_lines do
          call :next_level, :have_dinner
        end
      end

      it "first line is synopsis of missing required parameters" do
        _first_line == "'next-level' 'have-dinner' is missing required parameter 'money'.\n" or fail
      end

      it "second line is synopsis of unmet dependencies" do
        _second_line == "to 'next-level' 'have-dinner', must 'take-subway'\n" or fail
      end

      it "third line explains unmet dependency of above" do
        _line( 2 ) == "to 'take-subway', must 'get-card'\n" or fail
      end

      it "final line explains missing paramter (again) of this noe" do
        _line( 3 ) == "'get-card' is missing required parameter 'money'." or fail
      end
    end

    context "wahoo deep success" do

      call_by do

        call :money, '5', :next_level, :have_dinner
      end

      it "yay - result and no emissions.." do

        _expect = "(dinner: you have $5 (still!). #{
          }using '_subway_card_' you took subway here.)"

        _ = root_ACS_result
        _ == _expect or fail
      end

      # (emitted `set_leaf_component`)
    end

    def _first_line
      _line 0
    end

    def _second_line
      _line 1
    end

    def _line d
      _lines.fetch d
    end

    def _argument_error_lines & p

      _ev = rescue_argument_error_( & p )
      _ev.message.split %r((?<=\n))
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_50_Dep_Graphs ]::Subnode_01_Dinner
    end
  end
end
