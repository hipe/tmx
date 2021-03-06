require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - help permutations for component" do

    TS_[ self ]
    use :CLI_want_section_coarse_parse

    context "ask for help of bad node in first frame (as arg)" do

      given do
        argv '-h', 'not-an-ent'
      end

      it "fails" do
        want_exitstatus_for_referent_not_found_
      end

      it "first line says unrec" do
        first_line_content == "unrecognized node name \"not-an-ent\"" or fail
      end

      it "second line says did you mean" do
        expect( second_line ).to _match_did_you_mean_at_least_N_items 2
      end

      it "no invitation for futher help" do
        2 == number_of_lines or fail
      end
    end

    context "ask for help of bad node in second frame (as arg)" do

      given do
        argv '-h', 'compo2', 'x'
      end

      it "fails" do
        want_exitstatus_for_referent_not_found_
      end

      it "first line says unrec *contextualized*" do
        expect( first_line_content ).to eql %(unrecognized node name "x" in 'compo2')
      end

      it "did you mean (options at that node)" do
        expect( second_line ).to _match_did_you_mean_at_least_N_items 2
      end

      it "no invitation for further help" do
        2 == number_of_lines or fail
      end
    end

    context "ask for help of compound in first frame (as arg)" do

      given_screen do
        argv '-h', 'compo2'
      end

      it "succeeds" do
        want_result_for_success
      end

      it "two usage lines" do
        _jawn_2_usage_lines
      end

      it "desc for 2 is up top" do
        _jawn_2_upper_desc_is_2
      end

      it "desc for 3 is down below" do
        _jawn_2_lower_desc_is_3
      end

      it "invite looks right" do
        _jawn_2_invite_looks_right
      end
    end

    context "ask for help of compound in second frame (as arg)" do

      given_screen do
        argv '-h', 'compo2', 'compo3'
      end

      it "succeeds" do
        want_result_for_success
      end

      it "two usage lines" do
        _jawn_3_usage_lines
      end

      it "desc for 2 is up top" do
        _jawn_3_upper_desc_is_3
      end

      it "invite looks right" do
        _jawn_3_invite_looks_right
      end
    end

    context "ask for help of compound in first frame (not as arg)" do

      given_screen do
        argv 'compo2', '-h'
      end

      it "works - first line" do
        want_result_for_success
      end

      it "two usage lines" do
        _jawn_2_usage_lines
      end

      it "desc for 2 is up top" do
        _jawn_2_upper_desc_is_2
      end

      it "desc for 3 is down below" do
        _jawn_2_lower_desc_is_3
      end

      it "invite looks right" do
        _jawn_2_invite_looks_right
      end
    end

    context "ask for help of compound at level 2 (not as arg)" do

      given_screen do
        argv 'compo2', 'compo3', '-h'
      end

      it "works - first line" do
        want_result_for_success
      end

      it "two usage lines" do
        _jawn_3_usage_lines
      end

      it "desc for 2 is up top" do
        _jawn_3_upper_desc_is_3
      end

      it "invite looks right" do
        _jawn_3_invite_looks_right
      end
    end

    context "ask for help of compound at level 2 (not as THEN as arg)" do

      given_screen do
        argv 'compo2', '-h', 'compo3'
      end

      it "works - first line" do
        want_result_for_success
      end

      it "two usage lines" do
        _jawn_3_usage_lines
      end

      it "desc for 2 is up top" do
        _jawn_3_upper_desc_is_3
      end

      it "invite looks right" do
        _jawn_3_invite_looks_right
      end
    end

    def _jawn_2_usage_lines

      sect = section :usage
      same = 'compo2'
      expect( sect ).to _have_first_usage_line_of same
      expect( sect ).to _have_second_usage_line_of same
    end

    def _jawn_2_upper_desc_is_2

      expect( section :description ).to be_description_line_of :styled, 'C2'
    end

    def _jawn_2_lower_desc_is_3

      expect( section :actions ).to have_item_pair_of :styled, 'compo3', 'C3'
    end

    def _jawn_2_invite_looks_right

      expect( section :use ).to be_invite_line_of 'compo2'
    end

    def _jawn_3_usage_lines

      sect = section :usage
      same = 'compo2 compo3'
      expect( sect ).to _have_first_usage_line_of same
      expect( sect ).to _have_second_usage_line_of same
    end

    def _jawn_3_upper_desc_is_3

      expect( section :description ).to be_description_line_of :styled, 'C3'
    end

    def _jawn_3_invite_looks_right

      expect( section :use ).to be_invite_line_of 'compo2 compo3'
    end

    def _match_did_you_mean_at_least_N_items d

      s = %("[^"]+")
      if 1 < d
        _or_etc = "(?: or #{ s }){#{ d - 1 }}"
      end

      _rx = /\Adid you mean #{ s }#{ _or_etc }\?\z/

      # match_ expectation( :styled, :e, _rx )
      match_ expectation( :e, _rx )
    end

    def _have_first_usage_line_of s
      ___be_first_usage_line.for s, self
    end

    dangerous_memoize :___be_first_usage_line do

      regexp_based_matcher_by_ do |o|
        o.regexp = %r(\Ausage: xyzi ([^<]+) <action> \[named args\]$)
      o.line_offset = 0
      o.styled
      o.subject_noun_phrase = "first usage line"
      end
    end

    def _have_second_usage_line_of s
      ___be_second_usage_line.for s, self
    end

    dangerous_memoize :___be_second_usage_line do

      regexp_based_matcher_by_ do |o|
        o.regexp = %r(\A[ ]{2,}xyzi ([^-]+) -h <action>$)
      o.line_offset = 1
      o.styled
      o.subject_noun_phrase = "second usage line"
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_42_Complexica ]
    end
  end
end
