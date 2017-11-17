require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - string edit session stream via.." do

    TS_[ self ]
    use :memoizer_methods
    use :SES_common_DSL

    _EMPTY_RX = //

    context "empty regexp, empty string" do

      given do
        str EMPTY_S_
        rx _EMPTY_RX
      end

      string_edit_session_controllers_once_

      it "has one match controller" do
        want_one_match_
      end
    end

    context "empty regexp, non-empty string (2 chars wide)" do

      given do
        str 'ab'
        rx _EMPTY_RX
      end

      string_edit_session_controllers_once_

      it "has three match controllers" do
        number_of_match_controllers_.should eql 3
      end
    end

    _CHAR_RX = /./

    context "regexp that doesn't match string (empty string)" do

      given do
        str EMPTY_S_
        rx _CHAR_RX
      end

      string_edit_session_controllers_once_

      it "no matches" do
        want_no_matches_
      end
    end

    context "regexp that doesn't match string (nonempty string)" do

      given do
        str 'a'
        rx %r(b)
      end

      string_edit_session_controllers_once_

      it "no matches" do
        want_no_matches_
      end
    end

    context "two matches one line no newline" do

      given do
        str '__XX__XX__'
        rx %r(XX)
      end

      shared_string_edit_session_controllers_with_no_mutation_

      it "two matches" do
        number_of_match_controllers_.should eql 2
      end

      it "first match controller has the right offsets" do

        _at_idx_expect 0, 2, 4
      end

      it "second match controller has the right offsets" do

        _at_idx_expect 1, 6, 8
      end

      def _at_idx_expect d, beg, end_

        mc = match_controllers_.fetch d
        mc.match_charpos.should eql beg
        mc.match_end_charpos.should eql end_
      end
    end

    it "you can access the platform matchdata" do

      _s = 'Fibble..XX..and faBBle, and Fopple and falafel fubbel'
      _rx = /\bf[a-z][bp]{2}(?:el|le)\b/i

      _ = build_string_edit_session_controllers_ _s, _rx
      a = _.match_controller_array

      d = -1
      expect = -> s do
        d += 1
        a.fetch( d ).matchdata[ 0 ].should eql s
      end

      expect[ 'Fibble' ]
      expect[ 'faBBle' ]
      expect[ 'Fopple' ]
      expect[ 'fubbel' ]
      4 == a.length or fail
    end
  end
end
