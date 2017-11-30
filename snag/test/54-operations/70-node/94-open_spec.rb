require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - node - open" do

    TS_[ self ]
    use :want_event
    use :my_tmpdir_
    use :byte_up_and_downstreams

    it "nothing is reappropriable, so allocate a new number" do

      path = _td.write( 'foo/col-1.mani', _collection_one_string ).to_path
      # path = my_tmpdir_.join( 'foo/col-1.mani' ).to_path

      call_API(
        :node, :open,
        :try_to_reappropriate,
        :upstream_reference, path,
        :message,
<<-O.chop
1___ 1b__ 2___ 2b__ 3___ 3b__ 4___ 4b__ 5___ 5b__ 6___ 6b__ 7___ 7b__ 8___ 8b__
O
      )

      ev = want_OK_event( :wrote ).cached_event_value.to_event
      ev.bytes or fail
      ev.path or fail

      fh = ::File.open path
      expect( fh.gets ).to eql "[#03] B\n"
      expect( fh.gets ).to eql(
"[#002] #open 1___ 1b__ 2___ 2b__ 3___ 3b__ 4___ 4b__ 5___ 5b__ 6___ 6b__ 7___\n"
      )
      expect( fh.gets ).to eql "             7b__ 8___ 8b__\n"
      expect( fh.gets ).to eql "[#01] A\n"
      expect( fh.gets ).to be_nil
    end

    memoize :_collection_one_string do
      <<-HERE.unindent.freeze
        [#03] B
        [#01] A
      HERE
    end

    it "reappropriation" do

      # (#lend-coverage to [#fi-008.2])

      _did = downstream_ID_via_array_ y=[]

      _uid = upstream_reference_via_string_ <<-HERE.unindent.freeze
        [#02] #done  item 2 line one
          item 2 line two xyzyz
        [#03] B
        [#01] A
      HERE

      call_API(
        :node, :open,
        :try_to_reappropriate,
        :upstream_reference, _uid,
        :downstream_reference, _did,
        :message, "so far",
        :message, "so good",
      )

      expect( y[ 0 ] ).to eql(
"[#002] #open so far so good ( #was: #done  item 2 line one item 2 line two\n"
      )
      expect( y[ 1 ] ).to eql "             xyzyz )\n"
      expect( y[ 2 ] ).to eql "[#03] B\n"
      expect( y[ 3 ] ).to eql "[#01] A\n"
      expect( y.length ).to eql 4

      _node = @result
      expect( _node.ID.to_i ).to eql 2
    end

    def _td
      td = my_tmpdir_
      if td.exist?
        td
      else
        td.clear
      end
    end
  end
end
