require_relative '../test-support'

module Skylab::Basic::TestSupport::String

  describe "[ba] string - word wrappers - calm" do

    it "loads" do

      _subject
    end

    it "two words" do

      ww = _subject.new_with :margin, 'X',
        :width, 5,
        :downstream_yielder, []

      ww << 'foo bar'

      _y = ww.flush
      _y.should eql %w( Xfoo Xbar )
    end

    it "`input_words`, just one column too shy of a single line" do

      _subject.with(
        :width, 24,
        :input_words, %w( chaos computer collective ),
        :downstream_yielder, []

      ).should eql [ 'chaos computer', 'collective' ]
    end

    it "remove existing spaces and don't add spaces" do

      ww = _subject.new_with(
        :width, 3,
        :downstream_yielder, [] )

      ww << 'ab'
      ww << 'cd ef'
      ww << 'gh'

      ww.flush.should eql %w( ab cd ef gh )
    end

    it "breaks on hyphens" do

      _subject.with(
        :input_string, 'foo-bar',
        :width, 4,
        :downstream_yielder, []

      ).should eql [ 'foo-', 'bar' ]
    end

    it "won't break (on hyphens) if it's perfect fit for the one line" do

      _subject.with(
        :input_string, 'foo-bar',
        :width, 7,
        :downstream_yielder, []

      ).should eql [ 'foo-bar' ]
    end

    it "hyphenation - don't break a hyphenation before the hyphen" do

      _subject.with(
        :input_string, 'never re-think it',
        :width, 8,
        :downstream_yielder, []

      ).should eql %w( never re-think it )
    end

    it "hyphenation - do break a hyphenation afer the hyphen" do

      _subject.with(
        :input_string, 'never re-think it',
        :width, 9,
        :downstream_yielder, []

      ).should eql [ "never re-", "think it" ]
    end

    it "words longer than target width must be allowed in & out" do

      _subject.with(
        :input_string, 'on tw threez fo fi',
        :width, 5,
        :downstream_yielder, []

      ).should eql(
        [ 'on tw', 'threez', 'fo fi' ]
      )
    end

    it "amazingly, zero width doesn't bork" do

      _subject.with(
        :input_string, 'fe fi fo',
        :width, 0,
        :downstream_yielder, []

      ).should eql(
        [ 'fe', 'fi', 'fo' ] )
    end

    it "for now, negative width is borkless too" do

      _subject.with(
        :input_string, 'fe fi fo',
        :width, -1,
        :downstream_yielder, []

      ).should eql(
         [ 'fe', 'fi', 'fo' ]
      )
    end

    it "target edge case, the catalyst of the most recent rewrite" do

      a = _subject.with(
                     # 0___ 0b__ 1__
                     # [#xxx] #nepo Xxx
        :input_string, '#nepo 0b_ 1___ 1b__ 2___ 2b___',
        :skip_margin_on_first_line,
        :first_line_margin_width, 7,
        :margin, ( SPACE_ * 13 ),
        :width, 30,
        :downstream_yielder, []
      )

      2 == a.length or fail

      s1 = "[#xxx] #{ a.first }"
      s2 = a.last

      s1.should eql "[#xxx] #nepo 0b_ 1___ 1b__"
      s2.should eql "             2___ 2b___"
    end

    def _subject
      Basic_::String.word_wrappers.calm
    end
  end
end
