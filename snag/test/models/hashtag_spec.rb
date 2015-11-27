require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - hashtag" do

    extend TS_
    use :expect_piece

    context "parses" do

      it "empty string" do

        _scan ''
        expect_no_more_pieces_
      end

      it "string with only one space" do

        _scan SPACE_
        expect_piece_ :string, SPACE_
        expect_no_more_pieces_
      end

      it "string with only one tag" do

        _scan '#foo'
        expect_piece_ :hashtag, '#foo'
        expect_no_more_pieces_
      end

      it "two adjacent tags" do

        _scan '#a#b'
        expect_piece_ :hashtag, '#a'
        expect_piece_ :hashtag, '#b'
        expect_no_more_pieces_
      end

      it "minimal use-case of name-value extension" do

        st = _scan_with_values "#name: value\n"
        o = st.gets

        o.value_is_known_is_known.should eql true
        o.value_is_known.should eql true

        o.get_name_string.should eql '#name'
        o.get_value_string.should eql 'value'
        o.get_string.should eql '#name: value'

      end

      it "normal complexity" do

        _scan _normal_complexity
        expect_piece_ :string, 'this is some code '
        expect_piece_ :hashtag, '#public-API'
        expect_piece_ :string, ', '
        expect_piece_ :hashtag, '#bill-Deblazio'
        expect_piece_ :string, ':2014 wee'
        expect_no_more_pieces_
      end

      it "normal complexity (with name-value extension)" do

        _scan_with_values _normal_complexity
        expect_piece_ :string, 'this is some code '
        o = expect_piece_ :hashtag, '#public-API'
        o.value_is_known_is_known.should be_nil

        expect_piece_ :string, ', '

        o = expect_piece_ :hashtag, '#bill-Deblazio:2014'

        o.value_is_known.should eql true

        o.get_name_string.should eql '#bill-Deblazio'
        o.get_value_string.should eql '2014'

        expect_piece_ :string ,' wee'
        expect_no_more_pieces_
      end

      memoize :_normal_complexity do
        'this is some code #public-API, #bill-Deblazio:2014 wee'.freeze
      end

      it "edge case: a comma breaks the value" do  # :+#was:parse-values

        _scan '#foo:bar,baz'
        expect_piece_ :hashtag, '#foo'
        expect_piece_ :string, ':bar,baz'
        expect_no_more_pieces_
      end
    end

    context "the symbol classes are reflective" do

      it "you can 'get_stem_string' from a hash object" do

        _hashtag = __build_hashtag '#foo-bar'
        _hashtag.get_stem_string.should eql 'foo-bar'
      end
    end

    context "you can can flyweight across several lines" do

      it "x." do

        _scan "hi#there\n"
        expect_piece_ :string, 'hi'
        expect_piece_ :hashtag, '#there'
        expect_piece_ :string, "\n"
        expect_no_more_pieces_

        @piece_st.reinitialize_string_scanner_ "#there hi\n"
        expect_piece_ :hashtag, "#there"
        expect_piece_ :string, ' hi'
        expect_piece_ :string, "\n"
        expect_no_more_pieces_
      end
    end

    def __build_hashtag str

      st = _build_stream_via_string str
      o = st.gets
      st.gets and self._SANITY
      :hashtag == o.category_symbol or self._SANITY
      o
    end

    def _scan_with_values s

      st = _build_stream_via_string s
      st.become_name_value_scanner
      @piece_st = st
      st
    end

    def _scan s

      @piece_st = _build_stream_via_string s
      NIL_
    end

    def _build_stream_via_string s

      st = _subject::Stream.new
      st.initialize_string_scanner_ s
      st.init
      st
    end

    def _subject

      Home_::Models::Hashtag
    end
  end
end
