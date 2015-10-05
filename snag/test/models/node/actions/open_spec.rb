require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node - actions - open" do

    extend TS_
    use :expect_event
    use :my_tmpdir_
    use :byte_up_and_downstreams

    it "nothing is reappropriable, so allocate a new number" do

      path = _td.write( 'foo/col-1.mani', _collection_one_string ).to_path
      # path = my_tmpdir_.join( 'foo/col-1.mani' ).to_path

      call_API(
        :node, :open,
        :try_to_reappropriate,
        :upstream_identifier, path,
        :message, [
<<-O.chop
1___ 1b__ 2___ 2b__ 3___ 3b__ 4___ 4b__ 5___ 5b__ 6___ 6b__ 7___ 7b__ 8___ 8b__
O
        ] )

      ev = expect_OK_event( :wrote ).to_event
      ev.bytes or fail
      ev.path or fail

      fh = ::File.open path
      fh.gets.should eql "[#03] B\n"
      fh.gets.should eql(
"[#002] #open 1___ 1b__ 2___ 2b__ 3___ 3b__ 4___ 4b__ 5___ 5b__ 6___ 6b__ 7___\n"
      )
      fh.gets.should eql "             7b__ 8___ 8b__\n"
      fh.gets.should eql "[#01] A\n"
      fh.gets.should be_nil
    end

    memoize_ :_collection_one_string do
      <<-HERE.unindent.freeze
        [#03] B
        [#01] A
      HERE
    end

    it "reappropriation" do

      _did = downstream_ID_via_array_ y=[]

      _uid = upstream_identifier_via_string_ <<-HERE.unindent.freeze
        [#02] #done  item 2 line one
          item 2 line two xyzyz
        [#03] B
        [#01] A
      HERE

      call_API(
        :node, :open,
        :try_to_reappropriate,
        :upstream_identifier, _uid,
        :downstream_identifier, _did,
        :message, [ "so far", "so good" ]
      )

      y[ 0 ].should eql(
"[#002] #open so far so good ( #was: #done  item 2 line one item 2 line two\n"
      )
      y[ 1 ].should eql "             xyzyz )\n"
      y[ 2 ].should eql "[#03] B\n"
      y[ 3 ].should eql "[#01] A\n"
      y.length.should eql 4

      _node = @result
      _node.ID.to_i.should eql 2
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
