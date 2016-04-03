require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - help permutations for operation" do

    TS_[ self ]
    use :non_interactive_CLI_help_screens

    context "ask for help of any navigational *within* an oper. (as arg)" do

      given do
        argv '-h', 'ope1', 'wazo'
      end

      it "fails" do
        expect_exitstatus_for_referent_not_found_
      end

      it "very specific message" do

        _ = first_line_string.chomp!
        __ = second_line.string.chomp!

        _ == '"xyzi ope1" is an action. actions never have children.' or fail
        __ == 'as such it is meaningless to request for help on "wazo" here.' or fail
      end
    end

    context "ask for help of operation that is in first frame (as arg)" do

      given_screen do
        argv '-h', 'ope1'
      end

      it "succeeds" do
        expect_result_for_success
      end

      it "first usage line" do
        _jawn_1_first_usage_line
      end

      it "second usage line" do
        _jawn_1_second_usage_line
      end

      it "first description line" do
        _jawn_1_first_description_line
      end

      it "second description line" do
        _jawn_1_second_description_line
      end

      it "named arguments as items"

      it "invite"
    end

    context "ask for help of operation that is at level 2 (as arg)" do

      given_screen do
        argv '-h', 'compo2', 'ope2'
      end

      it "succeeds" do
        expect_result_for_success
      end

      it "first usage line" do
        _jawn_2_first_usage_line
      end

      it "second usage line" do
        _jawn_2_second_usage_line
      end

      it "named arguments as items"

      it "invite"
    end

    context "ask for help of operation that is in first frame (not as arg)" do

      given_screen do
        argv 'ope1', '-h'
      end

      it "succeeds" do
        expect_result_for_success
      end

      it "first usage line" do
        _jawn_1_first_usage_line
      end

      it "second usage line" do
        _jawn_1_second_usage_line
      end

      it "first description line" do
        _jawn_1_first_description_line
      end

      it "second description line" do
        _jawn_1_second_description_line
      end
    end

    context "ask for help of operation that is at level 2 (not as arg)" do

      given_screen do
        argv 'compo2', 'ope2', '-h'
      end

      it "succeeds" do
        expect_result_for_success
      end

      it "first usage line" do
        _jawn_2_first_usage_line
      end

      it "second usage line" do
        _jawn_2_second_usage_line
      end

      it "named arguments as items"

      it "invite"
    end

    def _jawn_1_first_usage_line
      section( :usage ).should have_first_usage_line_of 'ope1'
    end

    def _jawn_1_second_usage_line
      section( :usage ).should have_second_usage_line_of 'ope1'
    end

    def _jawn_1_first_description_line
      section( :description ).should be_description_line_of( :styled, 'OPE1' )
    end

    def _jawn_1_second_description_line
      _rx = %r(\A[ ]{2,}\(second line\)$)
      _li = section( :description ).line_at_offset 1
      _li.string =~ _rx or fail
    end

    def _jawn_2_first_usage_line
      section( :usage ).should have_first_usage_line_of 'compo2 ope2'
    end

    def _jawn_2_second_usage_line
      section( :usage ).should have_second_usage_line_of 'compo2 ope2'
    end

    dangerous_memoize :be_first_usage_line_ do

      o = begin_regex_based_matcher %r(\Ausage: xyzi ([^«]+) «NAMED ARGS PLACEHOLDER»$)
      o.line_offset = 0
      o.styled
      o.subject_noun_phrase = "first usage line"
      o
    end

    dangerous_memoize :be_second_usage_line_ do

      o = begin_regex_based_matcher %r(\A[ ]{2,}xyzi ([^-]+) -h <named-arg>$)
      o.line_offset = 1
      o.subject_noun_phrase = "second usage line"
      o
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_42_Complexica ]
    end
  end
end
