require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - tag - actions - delete" do

    extend TS_
    use :expect_event
    use :my_tmpdir_
    use :byte_up_and_downstreams
    use :node_support

    context "(with this manifest)" do

      it "node not found" do

        _call :node_identifier, 10, :tag, :x

        _ev = expect_not_OK_event :component_not_found

        _s = black_and_white _ev

        _s.should match(
          /\Athere is no node '\[#10\]' in [^ ]+sutherlands\./ )

        expect_failed
      end

      it "node is found but doesn't have tag" do

        _call :node_identifier, 1, :tag, :three

        _ev = expect_not_OK_event :component_not_found

        _s = black_and_white _ev

        _s.should eql(
          "node [#1] does not have tag '#three'" )  # :+[#015]

        expect_failed
      end

      it "remove a tag at the end" do

        _call :node_identifier, 1, :tag, :two,
          :downstream_identifier, downstream_ID_for_output_string_ivar_

        scn = scanner_via_output_string_
        scn.next_line.should eql "[#001]       keifer #one\n"
        scn.next_line.should eql "[#2] sutherland\n"
        scn.next_line.should eql "[#3]   donald #four\n"
        scn.next_line.should be_nil

        _ev = expect_OK_event :component_removed
        black_and_white( _ev ).should eql "removed tag #two from node [#1]"

        expect_noded_ 1
      end

      it "remove a tag in the middle (USE THE TEMPFILE)" do

        td = my_tmpdir_.clear

        pn = td.copy Fixture_file_[ :the_sutherlands_mani ], 'my-sutherlands'

        my_tmpfile_path = pn.to_path

        call_API :tag, :delete,
          :upstream_identifier, my_tmpfile_path,
          :node_identifier, 1, :tag, :one

        ev = expect_OK_event( :component_removed ).to_event
        ev.component.intern.should eql :one
        black_and_white( ev ).should eql "removed tag #one from node [#1]"

        @result.ID.to_i.should eql 1

        fh = ::File.open my_tmpfile_path
        fh.gets.should eql "[#001]       keifer #two\n"
        fh.close  # (um you already know the number of bytes)
      end

      def _call * x_a
        x_a[ 0, 0 ] = __common_head
        call_API_via_iambic x_a
      end

      memoize_ :__common_head do
        [ :tag, :delete,
          :upstream_identifier, Fixture_file_[ :the_sutherlands_mani ] ]
      end
    end
  end
end
