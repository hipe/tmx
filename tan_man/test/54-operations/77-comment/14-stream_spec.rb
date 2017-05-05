require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  TS_[ self ]

  describe "[tm] comment stream" do

    class << self
      def use m
        define_method :use_method do
          m
        end
      end
    end  # >>

    context "ordinary strings" do

# (1/N)
      it "the empty string is NO lines" do
        with EMPTY_S_
        expect
      end

# (2/N)
      it "a single newline is ONE line" do
        with NEWLINE_
        expect EMPTY_S_
      end

# (3/N)
      it "one line" do
        with "ohai\n"
        expect 'ohai'
      end

# (4/N)
      it "two lines" do
        with "foo\nbar"
        expect 'foo', 'bar'
      end

# (5/N)
      it "interceding blank lines are still there" do
        with "a\n\nc"
        expect 'a', EMPTY_S_, 'c'
      end

      use :of_string
    end


    context "shell style" do

# (6/N)
      it "one line" do
        with "  # zanger \n"
        expect ' zanger '
      end

# (7/N)
      it "two lines" do
        with " # feeple\n#deeple"
        expect ' feeple', 'deeple'
      end

      use :of_comment_string
    end

    context "c-style" do

# (8/N)
      it "one line" do
        with '/*ha*/'
        expect 'ha'
      end

# (9/N)
      it "two lines" do
        with "   /*  one\ntwo */  "
        expect '  one', 'two '
      end

      use :of_comment_string
    end

    def with s
      @s = s
    end

    def expect * s_a
      _subject = Home_::Models_::Comment::LineStream
      scn = _subject.send use_method, @s
      a = []
      while s = scn.gets
        a.push s
      end
      a.should eql s_a ; nil
    end

    # ==
    # ==
  end
end
