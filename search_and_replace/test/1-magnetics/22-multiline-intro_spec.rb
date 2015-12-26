require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (22) multiline intro" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_mutable_file_session

    _GAK = /\bGAK\b/

    context "minimal normal - one replacement in middle line in middle of line" do

      shared_subject :state_ do
        build_common_state_ "a\nb-GAK-c\nd\n", _GAK
      end

      it "one match" do
        expect_one_match_
      end

      it "three blocks - traverse from begin to end and back again" do

        _es = state_.edit_session
        bl1 = _es.first_block
        bl1 or fail

        bl2 = bl1.next_block
        bl2 or fail

        bl3 = bl2.next_block
        bl3 or fail

        _bl4 = bl3.next_block
        _bl4 and fail

        bl2_ = bl3.previous_block
        bl2_ or fail

        bl1_ = bl2_.previous_block
        bl1_ or fail

        _bl0 = bl1_.previous_block
        _bl0 and fail

        bl1.object_id == bl1_.object_id or fail
        bl2.object_id == bl2_.object_id or fail
      end
    end

    context "GAK//GAK" do

      _STRING = "GAK\nGAK"

      define_method :_build_the_session do
        build_edit_session_via_ _STRING, _GAK
      end

      it "one block - matches blocks are greedy" do

        # (we need to cover that that the parse gets initiatied by
        # this way and not the other way (thru the match controller)
        # so do NOT use the memoized guy for this..)

        _es = _build_the_session
        _b1_ = _es.first_block
        _b2_ = _b1_.next_block
        _b2_ and fail
      end

      it "two match controllers" do
        _es = _build_the_session
        _a = match_controller_array_for_ _es
        _a.length.should eql 2
      end
    end

    context "GAK//[ ]" do

      _STRING = "GAK\n__\n"

      shared_subject :state_ do

        _es = _build_the_session

        a = []
        b1 = _es.first_block
        if b1
          _ = b1.has_matches
          a.push _

          b2 = b1.next_block
          if b2
            _ = b2.has_matches
            a.push _
            _ = b2.next_block
            if _
              a.push :_failed_
            end
          end
        end
        a
      end

      define_method :_build_the_session do
        build_edit_session_via_ _STRING, _GAK
      end

      it "two blocks" do
        state_.length.should eql 2
      end

      it "first block has matches" do
        state_.fetch( 0 ).should eql true
      end

      it "second block does not" do
        state_.fetch( 1 ).should eql false
      end
    end

    context "GAK//[ ]//GAK" do

      _STRING = "GAK\n__\nGAK\n"

      shared_subject :state_ do

        _es = _build_the_session
        a = []
        curr = _es.first_block
        while curr
          _ = curr.has_matches
          a.push _
          curr = curr.next_block
        end
        a
      end

      define_method :_build_the_session do
        build_edit_session_via_ _STRING, _GAK
      end

      it "three blocks" do
        state_.length.should eql 3
      end

      it "matches look right" do
        state_.should eql [ true, false, true ]
      end
    end
  end
end
