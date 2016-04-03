require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - gamut A" do

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
        first_line.should be_line( :styled, :e, "expecting <compound-or-operation>" )
      end

      it "second line usage" do
        second_line.should be_stack_sensitive_usage_line
      end

      it "last line invite" do
        last_line.should be_invite_with_argument_focus
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
        first_line_string.should match %r(\Arequest cannot start with optio)
      end

      it "invite" do
        second_line.should be_invite_with_argument_focus
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
        first_line.string.should eql "unrecognized node name \"fuugee\"\n"
      end

      it "levenschtein (\"did you mean..\")" do
        second_line.should be_line( :styled, :e, %r(\Adid you mean 'add') )
      end

      it "invite" do
        last_line.should be_invite_with_argument_focus
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
        first_line_string.should match %r(\A'left-number' is not accessed wi)
      end

      it "invite with argument focus" do
        second_line.should be_invite_with_argument_focus
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
        first_line.should be_line "invalid option: --wotango"
      end

      it "invites" do
        second_line.should be_invite_with_option_focus
      end
    end

    context "an arg value is invalid (per model) (~#t8)" do

      given do
        argv 'add', '--left-number', 'one'
      end

      it "fails with specific exitstatus" do
        expect_exitstatus_for :_component_rejected_request_
      end

      it "treats operation name as verb and message as predicate" do

        _s = first_line_string
        _s.should eql "couldn't add because #{
          }left number didn't look like a simple number (had: \"one\")\n"
      end

      it "invites" do
        second_line.should be_invite_with_option_focus
      end
    end

    context "built op and parsed and args remain (#t9)" do

      given do
        argv 'add', '--left-number', '1', 'zing'
      end

      it "fails" do
        fails
      end

      it "whines" do
        first_line_string.should match %r(\Aunexpected argument: "zing")
      end
    end

    context "required args missing (#t10)", wip: true do

      given do
        argv 'add', '--left-number', '1'
      end

      it "fails" do
        fails
      end

      it "whines (NOTE currently not styled as option.. #wish [#032])" do

        _msg = "'add' is missing required parameter <right-number>."

        _be_this = match_ expectation( :styled, :e, _msg )

        first_line.should _be_this
      end

      it "invites" do

        _be_this = be_invite_with_no_focus

        second_line.should _be_this
      end
    end

    context "money (#t11)", wip: true do

      given do
        argv 'add', '--left-number', '5', '--right-number', '-2'
      end

      it "succeeds" do
        succeeds
      end

      it "the number resulted by the op written to STDOUT (*not* e.s)" do
        only_line.should be_line( :o, "3" )
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_11_Minimal_Postfix ]
    end
  end
end
