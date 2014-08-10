require_relative 'test-support'

module Skylab::Snag::TestSupport::Models::Hashtag__

  ::Skylab::Snag::TestSupport::Models[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  SPACE_ = Snag_::SPACE_

  describe "[sg] models hashtag" do

    context "parses" do

      it "empty string" do
        scan ''
        expect_no_more_parts
      end

      it "string with only one space" do
        scan SPACE_
        expect_part :string, SPACE_
        expect_no_more_parts
      end

      it "string with only one tag" do
        scan '#foo'
        expect_part :hashtag, '#foo'
        expect_no_more_parts
      end

      it "two adjacent tags" do
        scan '#a#b'
        expect_part :hashtag, '#a'
        expect_part :hashtag, '#b'
        expect_no_more_parts
      end

      it "normal complexity" do
        scan 'this is some code #public-API, #bill-Deblazio:2014'
        expect_part :string, 'this is some code '
        expect_part :hashtag, '#public-API'
        expect_part :string, ', '
        expect_part :hashtag, '#bill-Deblazio'
        expect_part :hashtag_name_value_separator, ':'
        expect_part :hashtag_value, '2014'
        expect_no_more_parts
      end
    end

    context "the symbol classes are reflective" do

      it "you can 'get_stem_s' from a hash object" do
        hashtag = build_hashtag '#foo-bar'
        hashtag.get_stem_s.should eql 'foo-bar'
      end
    end

    def build_hashtag str
      a = Subject_[].parse str
      1 == a.length and :hashtag == a.first.symbol_i or self._SANITY
      a.first
    end

    def expect_part i, x
      part = @part_a.shift or fail "expected more parts, had none"
      part.symbol_i.should eql i
      part.to_s.should eql x
    end

    def expect_no_more_parts
      @part_a.length.should be_zero
    end

    def scan s
      @part_a = Subject_[].parse s
    end

    Subject_ = -> do
      Snag_::Models::Hashtag
    end
  end
end
