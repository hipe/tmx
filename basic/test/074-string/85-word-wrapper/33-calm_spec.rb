require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - word wrappers - calm" do

    TS_[ self ]
    use :word_wrapper_calm

    it "loads" do
      subject_module_
    end

    it "two words" do

      ww = subject_with_(
        :margin, 'X',
        :width, 5,
        :downstream_yielder, []
      )

      ww << 'foo bar'

      _y = ww.flush
      expect( _y ).to eql %w( Xfoo Xbar )
    end

    it "`input_words`, just one column too shy of a single line" do

      expect( subject_via_(
        :width, 24,
        :input_words, %w( chaos computer collective ),
        :downstream_yielder, []

      ) ).to eql [ 'chaos computer', 'collective' ]
    end

    it "remove existing spaces and don't add spaces" do

      ww = subject_with_(
        :width, 3,
        :downstream_yielder, [] )

      ww << 'ab'
      ww << 'cd ef'
      ww << 'gh'

      expect( ww.flush ).to eql %w( ab cd ef gh )
    end

    it "breaks on hyphens" do

      expect( subject_via_(
        :input_string, 'foo-bar',
        :width, 4,
        :downstream_yielder, []

      ) ).to eql [ 'foo-', 'bar' ]
    end

    it "won't break (on hyphens) if it's perfect fit for the one line" do

      expect( subject_via_(
        :input_string, 'foo-bar',
        :width, 7,
        :downstream_yielder, []

      ) ).to eql [ 'foo-bar' ]
    end

    it "hyphenation - don't break a hyphenation before the hyphen" do

      expect( subject_via_(
        :input_string, 'never re-think it',
        :width, 8,
        :downstream_yielder, []

      ) ).to eql %w( never re-think it )
    end

    it "hyphenation - do break a hyphenation afer the hyphen" do

      expect( subject_via_(
        :input_string, 'never re-think it',
        :width, 9,
        :downstream_yielder, []

      ) ).to eql [ "never re-", "think it" ]
    end

    it "words longer than target width must be allowed in & out" do

      expect( subject_via_(
        :input_string, 'on tw threez fo fi',
        :width, 5,
        :downstream_yielder, []

      ) ).to eql(
        [ 'on tw', 'threez', 'fo fi' ]
      )
    end

    it "amazingly, zero width doesn't bork" do

      expect( subject_via_(
        :input_string, 'fe fi fo',
        :width, 0,
        :downstream_yielder, []

      ) ).to eql(
        [ 'fe', 'fi', 'fo' ] )
    end

    it "for now, negative width is borkless too" do

      expect( subject_via_(
        :input_string, 'fe fi fo',
        :width, -1,
        :downstream_yielder, []

      ) ).to eql(
         [ 'fe', 'fi', 'fo' ]
      )
    end

    _SPACE = ' '  # SPACE_

    it "target edge case, the catalyst of the most recent rewrite" do

      a = subject_via_(
                     # 0___ 0b__ 1__
                     # [#xxx] #nepo Xxx
        :input_string, '#nepo 0b_ 1___ 1b__ 2___ 2b___',
        :skip_margin_on_first_line,
        :first_line_margin_width, 7,
        :margin, ( _SPACE * 13 ),
        :width, 30,
        :downstream_yielder, []
      )

      2 == a.length or fail

      s1 = "[#xxx] #{ a.first }"
      s2 = a.last

      expect( s1 ).to eql "[#xxx] #nepo 0b_ 1___ 1b__"
      expect( s2 ).to eql "             2___ 2b___"
    end
  end
end
