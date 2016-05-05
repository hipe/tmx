require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - line scanner (multibyte bugfix)" do

    # all this time we've been happily trollomping along using *byte*
    # offsets when we should be using *character* offsets. this never
    # reached out to bite us until we parsed files (strings) with multibyte
    # characters in them, like "«" and "»"
    # (#guillemets. reminder: option [shift] backslash.)
    #
    # this is so close to the issue of [#011] that we might..

    TS_[ self ]

    it "don't bork over multibyte character sequences" do

      big_string = "_line 1_\n«line 2»\n_line 3_\n"
      p = _scan_proc_for big_string

      no1 = p[]
      no2 = p[]
      no3 = p[]

      _no4_ = p[]
      _no4_ and fail

      r = -> no do
        big_string[ no.charpos, no.sequence_width ]
      end

      r[ no1 ] == NEWLINE_ or fail
      r[ no2 ] == NEWLINE_ or fail
      r[ no3 ] == NEWLINE_ or fail
    end

    once = -> cls do
      once = nil
      cls.public_method_defined?( :gets ) or fail
    end

    define_method :_scan_proc_for do |big_string|

      cls = _subject_class
      once && once[ cls ]
      my_scn = cls.new big_string
      my_scn.respond_to? :gets or fail  # sanity - don't block for IO
      my_scn.method :gets
    end

    def _subject_class
      Home_::Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream::
          String_Edit_Session___::Line_Scanner_
    end
  end
end
