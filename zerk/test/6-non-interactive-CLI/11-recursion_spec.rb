require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] no-interactive CLI - recursion" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_help_screens

    context "help screen" do

      given_screen do
        argv 'next-lev', 'have-din', '-h'
      end

      it "works" do
        succeeds
      end

      it "usage line" do

        _bx = build_usage_line_index_of_first_usage_line
        _bx.a_[ 2..-1 ] == [ "next-level", "have-dinner", "<money>" ] or fail
      end

      it "option section is singular, has 1 item" do
        section( :option ).line_count == 2 or fail
      end
    end

    context "(mis req'd)" do

      given do
        argv 'next-lev', 'have-din'
      end

      it "fails" do
        expect_exitstatus_for :missing_required_parameters
      end

      it "explains" do

        _be_this_line = be_line( :styled, :e, "missing required argument <money>" )

        first_line.should _be_this_line
      end
    end

    context "( N.1 - invalid value )" do

      given do
        argv 'next-lev', 'have-din', '¥500'
      end

      it "fails" do
        expect_exitstatus_for :_component_rejected_request_
      end

      it "says elaborate thing (language a bit awkward per model)" do

        _exp = "couldn't have dinner next level because #{
         }money didn't look like a simple number (had: \"¥500\")"

        first_line_content == _exp or fail
      end

      it "invites about arguments" do
        last_line.should be_invite_with_argument_focus
      end
    end

    context "(yay)" do

      given do
        argv 'next-lev', 'have-din', '500'
      end

      it "succeeds" do
        succeeds
      end

      it "(first coverage of string-like results)" do

        _be_this_line = be_line :o, "(dinner: you have $500 (still!). #{
          }using '_subway_card_' you took subway here.)"

        first_line.should _be_this_line
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_50_Dep_Graphs ]::Subnode_01_Dinner
    end
  end
end
