require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - tag - delete" do

    TS_[ self ]
    use :want_event
    use :my_tmpdir_
    use :byte_up_and_downstreams
    use :nodes

    context "(with this manifest)" do

      it "node not found" do

        _call :node_identifier, 10, :tag, :x

        _em = want_not_OK_event :component_not_found

        expect( black_and_white _em.cached_event_value ).to match(
          /\Athere is no node "\[#10\]" in [^ ]+sutherlands\./ )

        want_fail
      end

      it "node is found but doesn't have tag" do

        _call :node_identifier, 1, :tag, :three

        _em = want_not_OK_event :component_not_found

        expect( black_and_white _em.cached_event_value ).to eql(
          "node [#1] does not have tag \"#three\"" )  # :+[#015]

        want_fail
      end

      it "remove a tag at the end" do

        _call :node_identifier, 1, :tag, :two,
          :downstream_reference, downstream_ID_for_output_string_ivar_

        scn = scanner_via_output_string_
        expect( scn.next_line ).to eql "[#001]       keifer #one\n"
        expect( scn.next_line ).to eql "[#2] sutherland\n"
        expect( scn.next_line ).to eql "[#3]   donald #four\n"
        expect( scn.next_line ).to be_nil

        _em = want_OK_event :component_removed

        expect( black_and_white _em.cached_event_value ).to eql(
          "removed tag #two from node [#1]" )

        want_noded_ 1
      end

      it "remove a tag in the middle (USE THE TEMPFILE)" do

        td = my_tmpdir_.clear

        pn = td.copy Fixture_file_[ :the_sutherlands_mani ], 'my-sutherlands'

        my_tmpfile_path = pn.to_path

        call_API :tag, :delete,
          :upstream_reference, my_tmpfile_path,
          :node_identifier, 1, :tag, :one

        ev = want_OK_event( :component_removed ).cached_event_value.to_event

        expect( ev.component.intern ).to eql :one

        expect( black_and_white ev ).to eql "removed tag #one from node [#1]"

        expect( @result.ID.to_i ).to eql 1

        fh = ::File.open my_tmpfile_path
        expect( fh.gets ).to eql "[#001]       keifer #two\n"
        fh.close  # (um you already know the number of bytes)
      end

      def _call * x_a
        x_a[ 0, 0 ] = __common_head
        call_API_via_iambic x_a
      end

      memoize :__common_head do
        [ :tag, :delete,
          :upstream_reference, Fixture_file_[ :the_sutherlands_mani ] ]
      end
    end
  end
end
