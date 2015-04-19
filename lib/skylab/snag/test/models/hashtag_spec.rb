require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - hashtag" do

    extend TS_

    context "parses" do

      it "empty string" do

        _scan ''
        _expect_no_more_parts
      end

      it "string with only one space" do

        _scan SPACE_
        _expect_part :string, SPACE_
        _expect_no_more_parts
      end

      it "string with only one tag" do

        _scan '#foo'
        _expect_part :hashtag, '#foo'
        _expect_no_more_parts
      end

      it "two adjacent tags" do

        _scan '#a#b'
        _expect_part :hashtag, '#a'
        _expect_part :hashtag, '#b'
        _expect_no_more_parts
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
        _expect_part :string, 'this is some code '
        _expect_part :hashtag, '#public-API'
        _expect_part :string, ', '
        _expect_part :hashtag, '#bill-Deblazio'
        _expect_part :string, ':2014 wee'
        _expect_no_more_parts
      end

      it "normal complexity (with name-value extension)" do

        _scan_with_values _normal_complexity
        _expect_part :string, 'this is some code '
        o = _expect_part :hashtag, '#public-API'
        o.value_is_known_is_known.should be_nil

        _expect_part :string, ', '

        o = _expect_part :hashtag, '#bill-Deblazio:2014'

        o.value_is_known.should eql true

        o.get_name_string.should eql '#bill-Deblazio'
        o.get_value_string.should eql '2014'

        _expect_part :string ,' wee'
        _expect_no_more_parts
      end

      memoize_ :_normal_complexity do
        'this is some code #public-API, #bill-Deblazio:2014 wee'.freeze
      end

      it "edge case: a comma breaks the value" do  # :+#was:parse-values

        _scan '#foo:bar,baz'
        _expect_part :hashtag, '#foo'
        _expect_part :string, ':bar,baz'
        _expect_no_more_parts
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
        _expect_part :string, 'hi'
        _expect_part :hashtag, '#there'
        _expect_part :string, "\n"
        _expect_no_more_parts

        @custom_st.change_input_string_ "#there hi\n"
        _expect_part :hashtag, "#there"
        _expect_part :string, ' hi'
        _expect_part :string, "\n"
        _expect_no_more_parts
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

      @custom_st = _build_stream_via_string( s ).to_name_value_scanner
    end

    def _scan s

      @custom_st = _build_stream_via_string s
      NIL_
    end

    def _build_stream_via_string s

      _subject::Stream[ s ]
    end

    def _expect_part i, x

      part = @custom_st.gets
      part or fail "expected more parts, had none"
      part.category_symbol.should eql i
      part.get_string.should eql x
      part
    end

    def _expect_no_more_parts

      x = @custom_st.gets
      x and fail "expecting no more parts, had #{ x.category_symbol }"
    end

    def _subject

      Snag_::Models::Hashtag
    end
  end
end
