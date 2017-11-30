require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - hashtag" do

    TS_[ self ]
    use :want_piece

    context "parses" do

      it "empty string" do

        _scan ''
        want_no_more_pieces_
      end

      it "string with only one space" do

        _scan SPACE_
        want_piece_ :string, SPACE_
        want_no_more_pieces_
      end

      it "string with only one tag" do

        _scan '#foo'
        want_piece_ :hashtag, '#foo'
        want_no_more_pieces_
      end

      it "two adjacent tags" do

        _scan '#a#b'
        want_piece_ :hashtag, '#a'
        want_piece_ :hashtag, '#b'
        want_no_more_pieces_
      end

      it "minimal use-case of name-value extension" do

        st = _scan_with_values "#name: value\n"
        o = st.gets

        expect( o.value_is_known_is_known ).to eql true
        expect( o.value_is_known ).to eql true

        expect( o.get_name_string ).to eql '#name'
        expect( o.get_value_string ).to eql 'value'
        expect( o.get_string ).to eql '#name: value'

      end

      it "normal complexity" do

        _scan _normal_complexity
        want_piece_ :string, 'this is some code '
        want_piece_ :hashtag, '#public-API'
        want_piece_ :string, ', '
        want_piece_ :hashtag, '#bill-Deblazio'
        want_piece_ :string, ':2014 wee'
        want_no_more_pieces_
      end

      it "normal complexity (with name-value extension)" do

        _scan_with_values _normal_complexity
        want_piece_ :string, 'this is some code '
        o = want_piece_ :hashtag, '#public-API'
        expect( o.value_is_known_is_known ).to be_nil

        want_piece_ :string, ', '

        o = want_piece_ :hashtag, '#bill-Deblazio:2014'

        expect( o.value_is_known ).to eql true

        expect( o.get_name_string ).to eql '#bill-Deblazio'
        expect( o.get_value_string ).to eql '2014'

        want_piece_ :string ,' wee'
        want_no_more_pieces_
      end

      memoize :_normal_complexity do
        'this is some code #public-API, #bill-Deblazio:2014 wee'.freeze
      end

      it "edge case: a comma breaks the value" do  # :+#was:parse-values

        _scan '#foo:bar,baz'
        want_piece_ :hashtag, '#foo'
        want_piece_ :string, ':bar,baz'
        want_no_more_pieces_
      end
    end

    context "the symbol classes are reflective" do

      it "you can 'get_stem_string' from a hash object" do

        _hashtag = __build_hashtag '#foo-bar'
        expect( _hashtag.get_stem_string ).to eql 'foo-bar'
      end
    end

    context "you can can flyweight across several lines" do

      it "x." do

        _scan "hi#there\n"
        want_piece_ :string, 'hi'
        want_piece_ :hashtag, '#there'
        want_piece_ :string, "\n"
        want_no_more_pieces_

        @piece_st.reinitialize_string_scanner_ "#there hi\n"
        want_piece_ :hashtag, "#there"
        want_piece_ :string, ' hi'
        want_piece_ :string, "\n"
        want_no_more_pieces_
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
