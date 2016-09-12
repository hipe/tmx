require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - quoted string literals" do

    it "loads" do
      _subject_library
    end

    context "(main)" do

      it "when no quote" do

        scn = _build_scanner_for "hi"
        _against_scanner scn
        _expect NIL_
        scn.pos == 0 || fail
      end

      it "when no escape sequences" do

        scn = _build_scanner_for "   \"foo\" and bar"  # 3 leading spaces
        scn.pos = 3

        _against_scanner scn
        _expect 'foo'

        scn.rest == " and bar" || fail
      end

      it "when yes escape sequence" do

        scn = _build_scanner_for  %q("i \\"love\\" it" he said)

        _against_scanner scn

        _expect 'i "love" it'

        scn.rest == " he said" or fail
      end

      def _expect x
        @_x == x || fail
      end

      def _against s
        _scn = _build_scanner_for s
        _against_scanner _scn
      end

      def _against_scanner scn
        @_x = _subject_library.unescape_quoted_literal_at_scanner_head scn
        NIL_
      end

      def _build_scanner_for s
        Home_.lib_.string_scanner s
      end
    end

    def _subject_library
      Home_::String.quoted_string_literal_library
    end
  end
end
