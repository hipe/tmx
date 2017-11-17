require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - multiline intro" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_common_DSL

    _GAK = /\bGAK\b/

    context "minimal normal - one replacement in middle line in middle of line" do

      given do
        str "a\nb-GAK-c\nd\n"
        rx _GAK
      end

      shared_string_edit_session_controllers_with_no_mutation_

      it "one match" do
        want_one_match_
      end

      it "three blocks - traverse from begin to end and back again" do

        _es = string_edit_session_controllers_.string_edit_session
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

      given do
        str "GAK\nGAK"
        rx _GAK
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

      given do
        str "GAK\n__\n"
        rx _GAK
      end

      shared_subject :_state do

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

      it "two blocks" do
        _state.length.should eql 2
      end

      it "first block has matches" do
        _state.fetch( 0 ).should eql true
      end

      it "second block does not" do
        _state.fetch( 1 ).should eql false
      end
    end

    context "GAK//[ ]//GAK" do

      given do
        str "GAK\n__\nGAK\n"
        rx _GAK
      end

      shared_subject :_state do

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

      it "three blocks" do
        _state.length.should eql 3
      end

      it "matches look right" do
        _state.should eql [ true, false, true ]
      end
    end

    def _build_the_session
      # (hi.)
      string_edit_session_begin_
    end
  end
end
