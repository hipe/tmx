# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe '[ze] CLI - want section magnetics - coarse parse' do

    TS_[ self ]
    use :memoizer_methods

    context 'basics' do

      it 'load me the module' do
        _subject_module_head_module || fail
      end

      it 'give me a coarse parse' do
        _coarse_parse || fail
      end

      it 'fetch me a known section from that coarse parse' do
        _section :itemizzios or fail
      end
    end

    context 'regexp based matcher' do

      context 'for one line' do

        it 'matcher builds' do
          _matcher_builds
        end

        it 'when not styled' do
          _against_section :descriptionone
          _s = _expect_failure_message
          expect( _s ).to _be_message_for_was_not_styled _this_rx, 'line'
        end

        it 'when styled but does not match' do
          _against_section :descriptiontwo
          _s = _expect_failure_message
          expect( _s ).to __be_message_for_regexp _this_jazooza, 'descriptiontwo: hello'
        end

        def __be_message_for_regexp subj_s, rx_s
          _super_rx = %r(\Aexpected #{ subj_s } to match /[^/]+/ - "#{ rx_s })  # #here2
          match _super_rx
        end

        it 'when does not match expected subexpression' do
          _against_section :descriptionthree
          _matcher = _matcher_prototype.for 'la la', :no_TCC_ZE
          _s = _expect_failure_message_via_matcher _matcher
          expect( _s ).to __be_message_for_string 'i am styled', 'la la', _this_jazooza
        end

        def __be_message_for_string act_s, exp_s, subj_s
          eql %(expected #{ subj_s } part to be "#{ exp_s }", had "#{ act_s }")  # #here2
        end

        shared_subject :_matcher_prototype do
          _matcher_class.define do |o|
            o.regexp = /\Adescription[a-z]+: hi (?<xxx>.+)/
            o.line_offset = 0
            o.styled
            o.subject_noun_phrase = _this_jazooza
          end
        end

        def _this_rx
          %r(\bdescriptionone: hi this )
        end

        def _this_jazooza
          'this jazooza'
        end
      end

      context 'multi line mode' do

        it 'matcher builds' do
          _matcher_builds
        end

        it 'when does not match any line in the section' do
          _against_section :itemizzios
          _s = _expect_failure_message
          expect( _s ).to __be_message_multi _this_rx
        end

        def __be_message_multi rx
          match %r(\Ano lines matched #{ ::Regexp.escape rx.inspect } \(of \d+ line\(s\)\))  # #here2  # oh my
        end

        shared_subject :_matcher_prototype do
          _matcher_class.define do |o|
            o.regexp = _this_rx
            o.match_any_line
            o.subject_noun_phrase = 'this jiffer'
          end
        end
      end

      def _this_rx
        /\bline four\b/
      end

      def _subject_module_tail
        :RegexpBasedMatcher__
      end
    end

    context 'item pair matcher' do

      it 'when first cel never found - tells how many lines' do

        _matcher = _matcher_by do |o|
          o.option_symbol = nil
          o.left_column_cel_string = 'chappa chuppa'
          o.right_column_cel_string = 'zwei'
        end
        _s = _message_via_matcher _matcher
        _exp_s = %q|not found: "chappa chuppa" (in 3 item lines)|  # #here2
        _s == _exp_s || fail
      end

      it %(when first cel found but second cel didn't match) do

        _matcher = _matcher_by do |o|
          o.option_symbol = nil
          o.left_column_cel_string = 'dos ni'
          o.right_column_cel_string = 'nein'
        end
        _s = _message_via_matcher _matcher
        _exp_s = "in second cel, #{ _say_wanted_had 'zwei', 'nein' }"  # #here2
        _s == _exp_s || fail
      end

      it 'when need styled but was not (note newline IS escaped)' do

        _matcher = _matcher_by do |o|
          o.option_symbol = :styled
          o.left_column_cel_string = 'uno ichi'
          o.right_column_cel_string = 'eins'
        end
        _s = _message_via_matcher _matcher
        expect( _s ).to _be_message_for_was_not_styled %r(  uno ichi  eins\\n), 'line'
      end

      it 'there is a mode for use against a particular line' do

        matcher = _matcher_by do |o|
          o.will_match_against_line_object
          o.option_symbol = nil
          o.left_column_cel_string = 'cha cho cha'
          o.right_column_cel_string = 'eins'
        end
        _sect = _section :itemizzios
        _line_o = _sect.second_line

        _yn = matcher.matches? _line_o
        _s = matcher.failure_message
        _exp_s = "in first cel, #{ _say_wanted_had 'uno ichi', 'cha cho cha' }"  # #here2
        _s == _exp_s || fail
      end

      def _message_via_matcher matcher
        _against_section :itemizzios
        _expect_failure_message_via_matcher matcher
      end

      def _matcher_by
        _matcher_class.define do |o|
          yield o
          o.mixed_test_context = :no_TCC_ZE
        end
      end

      def _subject_module_tail
        :ItemPairMatcher__
      end
    end

    context 'option index matcher' do

      it 'when no such short' do
        _given do |o|
          o.short_switch = '-chipotle'
        end
        _s = _flush_message
        _exp_s = %q(no "-chipotle" - had ["-m", "-g"])  # #here2
      end

      it 'when short but wrong long' do
        _given do |o|
          o.long_switch_plus = '--chipotle'
        end
        _s = _flush_message
        _exp_s = %q(wanted "--chipotle", had "--marmalade [=chachoga]")  # #here2
      end

      it %(when short and long and desc and desc doesn't match) do
        _given do |o|
          o.desc = 'chipotle desc'
        end
        _s = _flush_message
        expect( _s ).to _be_message_for_desc 'oh hai mamoosa', 'chipotle desc'
      end

      it 'when short and long and actual has desc and expected has no desc' do
        _given do |o|
          o.desc = nil  # while it works
        end
        _s = _flush_message
        expect( _s ).to _be_message_for_desc 'oh hai mamoosa', nil
      end

      it 'when everything else OK but expect styled and is not styled' do
        _given do |o|
          o.want_desc_was_styled = true
        end
        _s = _flush_message
        expect( _s ).to _be_message_for_was_not_styled %r(\boh hai mamoosa\b), 'item description'
      end

      it 'when everything else OK and actual is styled and styling not mentioned LOOK it matches' do

        _matcher = _matcher_class.define do |o|
          o.long_switch_plus = '--gagga THING'
          o.short_switch = '-g'
          o.desc = 'this is a styled desc'
          o.mixed_test_context = :no_TCC_ZE
        end

        _idx = _subject_option_index
        _yn = _matcher.matches? _idx
        true == _yn || fail
      end

      shared_subject :_matcher_prototype do

        # NOTE - in practical use we never use this as a dup-and-mutate
        # prototype; however, to employ this techinque for the purposes of
        # testing is fortunately as cheap as free

        _matcher_class.define do |o|
          o.long_switch_plus = '--marmalade [=chachoga]'
          o.short_switch = '-m'
          o.desc = 'oh hai mamoosa'
          o.mixed_test_context = :no_TCC_ZE
        end
      end

      def _flush_message
        matcher = remove_instance_variable :@MATCHER
        _idx = _subject_option_index
        _yn = matcher.matches? _idx
        false == _yn || fail
        matcher.failure_message
      end

      shared_subject :_subject_option_index do
        _sect = _section :optionistas
        _sect.to_option_index
      end

      def _given
        _proto = _matcher_prototype
        @MATCHER = _proto.new do |o|
          yield o
        end
      end

      def _subject_module_tail
        :OptionIndexMatcher___
      end
    end

    def _coarse_parse
      _coarse_parse_one
    end

    shared_subject :_coarse_parse_one do

      _coarse_parse_via_big_string <<~HERE
        descriptionone: hi this thing is for great life

        descriptiontwo: hello i am \e[32mstyled\e[0m

        descriptionthree: hi i am \e[32mstyled\e[0m

        optionistas:
          -m, --marmalade [=chachoga]  oh hai mamoosa
          -f  momma
          -g, --gagga THING  this is a \e[32mstyled\e[0m desc

        itemizzios
          uno ichi  eins
          dos ni  zwei

          tres san  drei
      HERE
    end

    # -- assertions

    # :#here2: indicates *every* place in this file that contains a surface
    # expression of a message string expectation (expressed either as a
    # regexps or literal string). when developing, grep this file on this
    # tag to get a list of these to serve as a reference towards what could
    # be reused (possibly thru abstraction). many of these are in-situ just
    # to reduce context jumps when reading.

    def _be_message_for_desc act_x, exp_x
      eql "desc didn't match. wanted #{ exp_x.inspect }, had #{ act_x.inspect }"  # #here2
    end

    def _say_wanted_had act_x, exp_x
      "wanted #{ exp_x.inspect }, had #{ act_x.inspect }"  # #here2 (fragment)
    end

    def _be_message_for_was_not_styled rx, subj_s
      match %r(\A#{ subj_s } was not styled - "#{ rx })  # #here2
    end

    def _expect_failure_message
      _matcher = _matcher_prototype.for :no_TCC_ZE
      _expect_failure_message_via_matcher _matcher
    end

    def _expect_failure_message_via_matcher matcher
      _sect = remove_instance_variable :@SECTION
      _yn = matcher.matches? _sect
      matcher.failure_message
    end

    def _against_section sym
      @SECTION = _section sym ; nil
    end

    def _matcher_builds
      _matcher_prototype || fail
    end

    # -- accessing components of coarse parsee

    def _section sym
      _cp = _coarse_parse
      _cp.section sym
    end

    # -- building coarse parse

    def _coarse_parse_via_big_string big_s

      _st = Home_.lib_.basic::String::LineStream_via_String[ big_s ].map_by do |line|
        X_cwscp_Line.new line
      end

      _scn = _st.flush_to_scanner

      _cls = _subject_module_head_module::CoarseParse___

      _cls.via_line_object_scanner _scn
    end

    def _matcher_class
      _subject_module_head_module.const_get _subject_module_tail, false
    end

    def _subject_module_head_module
      TS_::CLI::Want_Section_Coarse_Parse
    end

    # ==

    X_cwscp_Line = ::Struct.new :string

    # ==
    # ==
  end
end
# #born years later, because the custom matcher had no fail case coverage
