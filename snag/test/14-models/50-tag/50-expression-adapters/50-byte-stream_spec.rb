require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - tag - expression adapters - byte stream" do

    TS_[ self ]
    use :expect_piece
    use :expect_event

    context "a single-line case of medium complexity" do

      it "the 3 pieces before the structured tag look good" do

        # #lends-coverage to [#fi-008.10]

        _init_piece_stream
        expect_piece_ :string, 'hi '
        expect_piece_ :tag, '#normal-tag'
        expect_piece_ :string, ' '
      end

      it "the structured piece's `whole_string` includes the parens" do

        o = _nasty

        o.category_symbol.should eql :tag
        o.get_string.should eql '( #wiz: hey #other-tag hi )'
      end

      it "the structured piece's `get_name_string` is the tag only (no colon)" do

        _nasty.get_name_string.should eql '#wiz'
      end

      it "the structured piece's `get_value_string`: between colon & parens" do

        _nasty.get_value_string.should eql ' hey #other-tag hi '
      end

      it "the N pieces after the structured tag look as normal" do

        _init_piece_stream
        st = @piece_st
        4.times do
          st.gets
        end

        expect_piece_ :string, ' and '
        expect_piece_ :tag, '#normal-again'
        expect_piece_ :string, '.'
        expect_no_more_pieces_
      end

      dangerous_memoize :_nasty do

        _init_piece_stream
        st = @piece_st
        'hi ' == st.gets.get_string or self._SANITY
        st.gets  # normal tag
        st.gets  # a single space

        st.gets.dup
      end

      def _init_piece_stream

        call_API :node, :to_stream, :upstream_reference, _the_byte_upstream
        _node = @result.gets
        _body = _node.body
        @piece_st = _body.to_object_stream_
        NIL_
      end

      memoize :_the_byte_upstream do

        Home_.lib_.basic::String::ByteUpstreamReference.new(

          "[#07] hi #normal-tag ( #wiz: hey #other-tag hi ) and #normal-again.\n"
        )
      end
    end

    # context "quotes"

    # context "multiline"
  end
end
