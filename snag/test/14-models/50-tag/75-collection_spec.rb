require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - tag - collection" do

    # currently there is no actual "tag collection" asset node

    TS_[ self ]
    use :want_event
    use :byte_up_and_downstreams

    it "minimal positive case" do

      o = _subject.send :new

      o.append_tag :A, & handle_event_selectively_

      expect( o.to_tag_stream.map_by do | tag |
        tag.intern
      end.to_a ).to eql [ :A ]

      want_no_events
    end

    it "don't use the hash character here" do

      o = _subject.send :new

      ok = o.prepend_tag :"#A", & handle_event_selectively_

      _em = want_not_OK_event :invalid_tag_stem

      expect( _em.cached_event_value.tag_s ).to eql '##A'

      expect( ok ).to eql false
    end

    it "create then express as byte stream" do

      o = _subject.send :new, _id( 3 )  # the node identifier is '3'

      o.append_tag :love
      o.append_string 'this'
      o.prepend_string 'we really '

      o.express_into_under a=[], _expag( 23, 3, 2 )
      want_these_lines_in_array_ a do |y|
        y << "[#03]   we really #love\n"
        y << "        this\n"
      end
    end

    it "read from byte-stream" do

      o = _subject.via_body _body
      st = o.to_tag_stream

      tag = st.gets
      expect( tag.category_symbol ).to eql :tag
      expect( tag.intern ).to eql :foo

      tag = st.gets
      expect( tag.intern ).to eql :ha

      tag = st.gets
      expect( tag.intern ).to eql :ha

      expect( st.gets ).to be_nil
    end

    it "read from byte-stream then prepend" do

      o = _new_node_via_identifier_and_body _id( 4 ), _body

      _ok = o.prepend_tag :boo, & handle_event_selectively_
      want_no_events
      _ok or fail

      o.express_N_units_into_under 3, y=[], _expag( 23, 7, 3 )

      __want_prepended y
    end

    def __want_prepended actual

      want_these_lines_in_array_with_trailing_newlines_ actual do |y|
        y << "not a business line"
        y << "[#004]       #boo #foo"
        y << "             goo hoo"
        y << "             just a"
        y << "again not business"  # NOTE currently the non-
        # business head and tail caps are unaware of requests for N units only
      end
    end

    it "read from byte-stream then append (it only re-writes the necessary lines)" do

      o = _new_node_via_identifier_and_body _id( 3 ), _body

      _ok = o.append_tag :zoo, & handle_event_selectively_
      want_no_events
      _ok or fail

      y =[]
      o.express_into_under( y, _expag( 22, 7, 3 ) )
      __want_appended y
    end

    def __want_appended actual

      a = _body.send :_sstr_a
      want_these_lines_in_array_ actual do |y|
        y << a[0].s
        y << a[1].s
        y << a[2].s
        y << "             #ha #ha\n"
        y << "             #zoo\n"
        y << "again not business\n"
      end
    end

    alias_method :_expag, :build_byte_stream_expag_

    def _new_node_via_identifier_and_body id, body

      Home_::Models_::Node.send :new, id, body
    end

    def _id d
      Home_::Models_::NodeIdentifier.send :new, nil, d
    end

    memoize :_body do

      o = Home_::Models_::Node::ExpressionAdapters::ByteStream::Models_

      o::Body.via_range_and_substring_array( 1...4, [
        o::Substring.new( nil, nil, "not a business line\n" ),
        o::Substring.new( 2, 13, "XX#foo goo hoo\n" ),
        o::Substring.new( 2, 17, "XX just a string \n" ),
        o::Substring.new( 2,  8, "XX#ha#ha\n" ),
        o::Substring.new( nil, nil, "again not business\n" ) ] )
    end

    def _subject
      Home_::Models_::Node  # for now
    end
  end
end
