require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (20) mutable file session stream (intro)", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_mutable_file_session

    _EMPTY_RX = //

    context "empty regexp, empty string" do

      shared_subject :state_ do
        build_common_state_ EMPTY_S_, _EMPTY_RX
      end

      it "has one match controller" do
        expect_one_match_
      end
    end

    context "empty regexp, non-empty string (2 chars wide)" do

      shared_subject :state_ do
        build_common_state_ 'ab', _EMPTY_RX
      end

      it "has three match controllers" do
        number_of_match_controllers_.should eql 3
      end
    end

    _CHAR_RX = /./

    context "regexp that doesn't match string (empty string)" do

      shared_subject :state_ do
        build_common_state_ EMPTY_S_, _CHAR_RX
      end

      it "no matches" do
        expect_no_matches_
      end
    end

    context "regexp that doesn't match string (nonempty string)" do

      shared_subject :state_ do
        build_common_state_ 'a', /b/
      end

      it "no matches" do
        expect_no_matches_
      end
    end

    context "two matches one line no newline" do

      shared_subject :state_ do
        build_common_state_ '__XX__XX__', /XX/
      end

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

      _ = build_common_state_ _s, _rx
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
