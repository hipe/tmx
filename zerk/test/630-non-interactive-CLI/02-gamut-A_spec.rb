require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - gamut A (used to need o.p, now does not)" do

    TS_[ self ]
    use :non_interactive_CLI

    context "no args at all (#t1)" do

      given do
        argv
      end

      it "fails" do
        fails
      end

      it "first line" do
        expect( first_line ).to be_line( :styled, :e, "expecting <compound-or-operation>" )
      end

      it "second line usage" do
        expect( second_line ).to be_stack_sensitive_usage_line
      end

      it "last line invite" do
        expect( last_line ).to be_invite_with_argument_focus
      end
    end

    context "dash before any operations (not help) (#t2)" do

      given do
        argv '--zappos'
      end

      it "fails" do
        fails
      end

      it "whines" do
        expect( first_line_string ).to match %r(\Arequest cannot start with optio)
      end

      it "invite" do
        expect( second_line ).to be_invite_with_argument_focus
      end
    end

    context "unrecognzied plain token (#t3)" do

      given do
        argv 'fuugee'
      end

      it "fails" do
        fails
      end

      it "whines" do
        expect( first_line.string ).to eql "unrecognized node name \"fuugee\"\n"
      end

      it "levenschtein (\"did you mean..\")" do
        expect( second_line ).to be_line( :e, %r(\Adid you mean "add") )
      end

      it "invite" do
        expect( last_line ).to be_invite_with_argument_focus
      end
    end

    context "what strange token is this (#t4)" do

      given do
        argv 'left-number', '1'  # wrong b.c is not written as option
      end

      it "fails" do
        fails
      end

      it "whines" do
        expect( first_line_string ).to match(
          %r(\A'left-number' \(a primitivesque\) is not accessed wi) )
      end

      it "invite with argument focus" do
        expect( second_line ).to be_invite_with_argument_focus
      end
    end

    context "built o.p and failed its parse (#t8)" do

      given do
        argv 'add', '--wotango', 'xx'
      end

      it "fails" do
        fails
      end

      it "whines" do
        expect( first_line ).to be_line "invalid option: --wotango"
      end

      it "invites" do
        expect( second_line ).to be_invite_with_option_focus
      end
    end

    context "an arg value is invalid (per model) (~#t8)" do

      given do
        argv 'add', '1', 'two'
      end

      it "fails with specific exitstatus" do
        want_exitstatus_for :component_rejected_request
      end

      it "treats operation name as verb and message as predicate" do

        first_line_string == "couldn't add because right number #{
          }didn't look like a simple number (had: \"two\")\n" or fail
      end

      it "invites" do
        expect( second_line ).to be_invite_with_argument_focus
      end
    end

    context "args remain (#t9)" do

      given do
        argv 'add', '1', '2', 'three'
      end

      it "fails" do
        want_exitstatus_for :_parse_error_
      end

      it "whines" do
        expect( first_line_string ).to match %r(\Aunexpected argument: "three")
      end

      it "invites specifically" do
        expect( last_line ).to be_invite_with_argument_focus
      end
    end

    context "required args missing (#t10)" do

      given do
        argv 'add', '1'
      end

      it "fails" do
        want_exitstatus_for :missing_required_parameters
      end

      it "whines about missing required argument (knows it is an argument)" do

        _msg = "missing required argument <right-number>"

        _be_this = match_ expectation( :styled, :e, _msg )

        expect( first_line ).to _be_this
      end

      it "invites with argument focus" do

        expect( second_line ).to be_invite_with_argument_focus
      end
    end

    context "money (#t11)" do

      given do
        argv 'add', '5', '--', '-2'
      end

      it "succeeds" do
        succeeds
      end

      it "the number resulted by the op written to STDOUT (*not* e.s)" do
        expect( only_line ).to be_line( :o, "3" )
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_11_Minimal_Postfix ]
    end
  end
end
