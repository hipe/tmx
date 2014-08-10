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
        expect_part :hashtag, '#bill-Deblazio:2014'
        expect_no_more_parts
      end
    end

    context "simple" do

      tag = -> ctx do
        r = ctx.build_tag '#foo-bar'
        tag = -> _ { r } ; r
      end

      it "means it does not have a colon" do
        tg = tag[ self ]
        tg.is_simple.should eql true
        tg.is_complex.should eql false
      end

      it "'to_stem_and_value' is as is expected" do
        arr = tag[ self ].to_stem_and_value
        arr.length.should eql 2
        s, v = arr
        s.should eql 'foo-bar'
        v.should be_nil
      end

      it "'get_stem' works" do
        tag[ self ].get_stem.should eql 'foo-bar'
      end
    end

    context "complex" do

      tag = -> ctx do
        r = ctx.build_tag '#priority:low:very'
        tag = -> _ { r } ; r
      end

      it "means it does have a colon" do
        tg = tag[ self ]
        tg.is_simple.should eql false
        tg.is_complex.should eql true
      end

      it "'to_stem_and_value' is as is expected" do
        arr = tag[ self ].to_stem_and_value
        arr.length.should eql 2
        s, v = arr
        s.should eql 'priority'
        v.should eql 'low:very'
      end

      it "'get_stem' works" do
        tag[ self ].get_stem.should eql 'priority'
      end
    end

    def build_tag str
      scan str
      1 == @part_a.length and :hashtag == @part_a.first.type_i or fail "sanity"
      @part_a.shift
    end

    def expect_part i, x
      part = @part_a.shift or fail "expected more parts, had none"
      part.type_i.should eql i
      part.to_s.should eql x
    end

    def expect_no_more_parts
      @part_a.length.should be_zero
    end

    def scan s
      @part_a = Snag_::Models::Hashtag::Parse[ :_listener_not_used_, s ]
    end
  end
end
