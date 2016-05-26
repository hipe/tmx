require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - line scanner (multibyte bugfix)" do

    # all this time we've been happily trollomping along using *byte*
    # offsets when we should have be using *character* offsets. this never
    # reached out to bite us until we parsed files (strings) with multibyte
    # characters in them, like "«" and "»"
    # (#guillemets. reminder: option [shift] backslash.)
    #
    # this is so close to the issue of [#011] that we might..

    TS_[ self ]

    it "one normal line" do
      _to_a( "foo\n" ) == [ 'foo' ] or fail
    end

    it "one non-terminated line" do

      p = _scan_proc_for 'foo'
      no = p[]
      p[] and fail
      no.charpos == 3 or fail
      no.end_charpos == 3 or fail
    end

    it "for now, empty file still sees it as having a final terminator" do

      p = _scan_proc_for EMPTY_S_
      no = p[]
      p[] and fail

      no.charpos.zero? or fail
      no.end_charpos.zero? or fail
    end

    it "don't bork over multibyte character sequences" do

      big_string = "_line 1_\n«line 2»\n_line 3_\n"
      p = _scan_proc_for big_string

      no1 = p[]
      no2 = p[]
      no3 = p[]

      _no4_ = p[]
      _no4_ and fail

      p = _reader_of big_string

      p[ no1 ] == NEWLINE_ or fail
      p[ no2 ] == NEWLINE_ or fail
      p[ no3 ] == NEWLINE_ or fail
    end

    it "multibyte, multi-line with no terminating sequence" do

      hi = "«foo»\r\nbar"
      p = _scan_proc_for hi
      no1 = p[]
      no2 = p[]
      p[] and fail

      no1.charpos == 5 or fail
      no1.end_charpos == 7 or fail

      no2.charpos == 10 or fail
      no2.end_charpos == 10 or fail
    end

    it "change mojo mid-parse" do

      a = _to_a "«foo»\r\nbar\r\r\rbaz\nboffo"
      a[0] == "«foo»" or fail
      a[1] == "bar" or fail
      a[2].length.zero? or fail
      a[3].length.zero? or fail
      a[4] == "baz" or fail
      a[5] == "boffo" or fail
    end

    def _to_a big_string
      a = []
      p = _scan_proc_for big_string
      d = 0
      begin
        no = p[]
        no or break
        a.push big_string[ d ... no.charpos ]
        d = no.end_charpos
        redo
      end while nil
      a
    end

    def _scan_proc_for big_string

      o = SES::Build_line_scanner[ big_string ]

      # (saying `method( :gets )` instead of the below might accidentally
      # hang blocking for IO, if we accidentally grab the private method)

      -> do
        o.gets
      end
    end

    def _reader_of s
      -> no do
        s[ no.charpos, no.sequence_width ]
      end
    end
  end
end
