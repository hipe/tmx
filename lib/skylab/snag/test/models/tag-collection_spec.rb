require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - tag collection" do

    # currently there is no actual "tag collection" asset node

    extend TS_
    use :expect_event

    it "minimal positive case" do

      o = _subject.new

      o.append_tag :A, & handle_event_selectively

      o.to_tag_stream.map_by do | tag |
        tag.intern
      end.to_a.should eql [ :A ]

      expect_no_events
    end

    it "don't use the hash character here" do

      o = _subject.new

      ok = o.prepend_tag :"#A", & handle_event_selectively

      expect_not_OK_event( :invalid_tag_stem ).tag_s.should eql '##A'

      ok.should eql false
    end

    it "create then express as byte stream" do

      o = _subject.new 3  # the node identifier is '3'
      o.append_tag :love
      o.append_string 'this'
      o.prepend_string 'we really '

      o.express_into_under y=[], _expag( 23, 3, 2 )
      y[ 0 ].should eql "[#03]   we really #love\n"
      y[ 1 ].should eql "        this\n"
      y[ 2 ].should be_nil
    end

    it "read from byte-stream" do

      o = _subject.new nil, _body
      st = o.to_tag_stream

      tag = st.gets
      tag.business_category_symbol.should eql :tag
      tag.intern.should eql :foo

      tag = st.gets
      tag.intern.should eql :ha

      tag = st.gets
      tag.intern.should eql :ha

      st.gets.should be_nil
    end

    it "read from byte-strem then prepend" do

      o = _subject.new _id( 4 ), _body

      _ok = o.prepend_tag :boo, & handle_event_selectively
      expect_no_events
      _ok or fail

      o.express_N_units_into_under 3, y=[], _expag( 23, 7, 3 )

      __expect_prepended y
    end

    def __expect_prepended y

      y[ 0 ].should eql "not a business line\n"
      y[ 1 ].should eql "[#004]       #boo #foo\n"
      y[ 2 ].should eql "             goo hoo\n"
      y[ 3 ].should eql "             just a\n"
      y[ 4 ].should eql "again not business\n"  # NOTE currently the non-
        # business head and tail caps are unaware of requests for N units only
      y[ 5 ].should be_nil

    end

    it "read from byte-stream then append (it only re-writes the necessary lines)" do

      o = _subject.new _id( 3 ), _body

      _ok = o.append_tag :zoo, & handle_event_selectively
      expect_no_events
      _ok or fail

      y =[]
      o.express_into_under( y, _expag( 22, 7, 3 ) )
      __expect_appended y
    end

    def __expect_appended y

      a = _body.instance_variable_get( :@sstr_a )
      y[ 0 ].should eql a[ 0 ].s
      y[ 1 ].should eql a[ 1 ].s
      y[ 2 ].should eql a[ 2 ].s
      y[ 3 ].should eql "             #ha #ha\n"
      y[ 4 ].should eql "             #zoo\n"
      y[ 5 ].should eql "again not business\n"
      y[ 6 ].should be_nil

    end

    def _expag d, d_, d__
      Snag_::Models_::Node::Expression_Adapters::Byte_Stream::Sessions_::Expag___.
        new( d, d_, d__ )
    end

    def _id d
      Snag_::Models_::Node_Identifier.new_via_integer d
    end

    memoize_ :_body do

      o = Snag_::Models_::Node::Expression_Adapters::Byte_Stream::Models_

      o::Body.via_range_and_substring_array( 1...4, [
        o::Substring.new( nil, nil, "not a business line\n" ),
        o::Substring.new( 2, 13, "XX#foo goo hoo\n" ),
        o::Substring.new( 2, 17, "XX just a string \n" ),
        o::Substring.new( 2,  8, "XX#ha#ha\n" ),
        o::Substring.new( nil, nil, "again not business\n" ) ] )
    end

    def _subject
      Snag_::Models_::Node  # for now
    end
  end
end
