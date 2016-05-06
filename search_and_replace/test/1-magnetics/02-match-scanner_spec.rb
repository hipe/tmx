require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - match scanner (multibyte bugfix)" do

    TS_[ self ]
    use :magnetics_match_scanner_DSL

    context "no match is OK" do

      given do
        rx %r(none)
        str 'some'
      end

      it "no matches" do
        matches_count == 0 or fail
      end
    end

    context "match the empty regex on the empty string" do

      given do
        rx %r()
        str EMPTY_S_
      end

      it "ONLY one match" do
        matches_count == 1 or fail
      end

      it "the match reports zero width" do
        o = _the_match
        o.charpos.zero? or fail
        o.end_charpos.zero? or fail
      end

      def _the_match
        match_scanner_array.fetch 0
      end
    end

    context "normal with ascii" do

      given do
        rx %r(o)
        str 'moon'
      end

      it "offsets are right" do
        _at( :charpos ) == [ 1, 2 ] or fail
      end

      it "look at these endpoints" do
        _at( :end_charpos ) == [ 2, 3 ] or fail
      end
    end

    context "normal with multibyte" do

      given do
        rx %r(«[^»]+»)
        str "01«34»6«8»"
      end

      it "matches" do
        matches_count == 2 or fail
      end

      it "offsets are character based (not byte based)" do

        _at( :charpos ) == [ 2, 7 ] or fail
      end

      it "enpoints are one later than you might think" do

        _at( :end_charpos ) == [ 6, 10 ] or fail
      end
    end

    def _at m
      match_scanner_array.map( & m )
    end
  end
end
