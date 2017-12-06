require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - help permutations for operation" do

    TS_[ self ]
    use :CLI_want_section_coarse_parse

    context "ask for help of any navigational *within* an oper. (as arg)" do

      given do
        argv '-h', 'ope1', 'wazo'
      end

      it "fails" do
        want_exitstatus_for_referent_not_found_
      end

      it "very specific message" do

        _ = first_line_string.chomp!
        __ = second_line.string.chomp!

        _ == '"xyzi ope1" is an action. actions never have children.' or fail
        __ == 'as such it is meaningless to request for help on "wazo" here.' or fail
      end
    end

    # (:#here marks #open [#035] whether we invite after operation help screens)

    context "ask for help of operation that is in first frame (as arg)" do

      given_screen do
        argv '-h', 'ope1'
      end

      it "succeeds" do
        want_result_for_success
      end

      it "first usage line" do
        _jawn_1_first_usage_line
      end

      it "no second usage line" do
        _no_second_usage_line
      end

      it "first description line" do
        _jawn_1_first_description_line
      end

      it "second description line" do
        _jawn_1_second_description_line
      end

      it "named arguments as items" do
        _jawn_1_options_section
      end

      it "invite"  # #here
    end

    context "ask for help of operation that is at level 2 (as arg)" do

      given_screen do
        argv '-h', 'compo2', 'ope2'
      end

      it "succeeds" do
        want_result_for_success
      end

      it "first usage line" do
        _jawn_2_first_usage_line
      end

      it "no second usage line" do
        _no_second_usage_line
      end

      it "named arguments as items" do
        _jawn_2_options_section
      end

      it "invite"  # #here
    end

    context "ask for help of operation that is in first frame (not as arg)" do

      given_screen do
        argv 'ope1', '-h'
      end

      it "succeeds" do
        want_result_for_success
      end

      it "first usage line" do
        _jawn_1_first_usage_line
      end

      it "second usage line" do
        _no_second_usage_line
      end

      it "first description line" do
        _jawn_1_first_description_line
      end

      it "second description line" do
        _jawn_1_second_description_line
      end

      it "invite"  # #here
    end

    context "ask for help of operation that is at level 2 (not as arg)" do

      given_screen do
        argv 'compo2', 'ope2', '-h'
      end

      it "succeeds" do
        want_result_for_success
      end

      it "first usage line" do
        _jawn_2_first_usage_line
      end

      it "no second usage line" do
        _no_second_usage_line
      end

      it "named arguments as items" do
        _jawn_2_options_section
      end

      it "invite"  # #here
    end

    def _no_second_usage_line
      2 == section( :usage ).line_count or fail
    end

    def _jawn_1_first_usage_line
      expect( section :usage ).to _have_first_usage_line 'ope1 [-p X]'
    end

    def _jawn_1_first_description_line
      expect( section :description ).to be_description_line_of( :styled, 'OPE1' )
    end

    def _jawn_1_second_description_line
      _rx = %r(\A[ ]{2,}\(second line\)$)
      _li = section( :description ).line_at_offset 1
      _li.string =~ _rx or fail
    end

    def _jawn_2_first_usage_line
      expect( section :usage ).to _have_first_usage_line 'compo2 ope2 [-p X]'
    end

    def _jawn_1_options_section
      _sect = section :options
      st = _sect.to_line_stream
      st.gets
      st.gets
      _3rd = st.gets
      _4th = st.gets
      _3rd.string == "    -p, --primi1 X\n" or fail
      _4th and fail
    end

    def _jawn_2_options_section
      _sect = section :options
      st = _sect.to_line_stream
      st.gets
      st.gets
      _3rd = st.gets
      _4th = st.gets
      _5th = st.gets
      _3rd.string == "    -p, --primi2 X\n" or fail
      _4th.string == "        --primi1 X\n" or fail
      _5th and fail
    end

    def _have_first_usage_line s
      ___be_first_usage_line.for s, self
    end

    dangerous_memoize :___be_first_usage_line do

      regexp_based_matcher_by_ do |o|
        o.regexp = %r(\Ausage: xyzi (.+)$)
      o.line_offset = 0
      o.styled
      o.subject_noun_phrase = "first usage line"
      end
    end

    def _have_second_usage_line_argless_of s
      ___be_second_usage_line_argless.for s, self
    end

    dangerous_memoize :___be_second_usage_line_argless do

      regexp_based_matcher_by_ do |o|
        o.regexp = %r(\A[ ]{2,}xyzi ([^-]+) -h$)
      o.line_offset = 1
      o.subject_noun_phrase = "second usage line"
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_42_Complexica ]
    end
  end
end
