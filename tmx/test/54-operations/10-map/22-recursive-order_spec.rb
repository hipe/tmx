require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - recursive" do

    TS_[ self ]
    use :operations_map

    context "can't use :result_in_tree unless it's relevant" do

      call_by do
        call :map, :result_in_tree
      end

      it "fails" do
        fails
      end

      it "explain" do
        em = expect_parse_error_emission_
        _act = em.express_into_under "", expag_
        _act == ":result_in_tree must occur after :order." || fail
      end
    end

    context "egads" do

      call_by do

        _st = json_file_stream_GA_

        call( :map,
          :json_file_stream, _st,
          * real_attributes_,
          :order, :category,
          :order, :cost,
          :result_in_tree,  # put this anywhere, here for coverage
          :order, :doc_test_manifest,
        )
      end

      expect_no_events

      it "egads" do

        _tree = __result_tree
        _st = _tree.to_node_stream
        @_eek = _st.to_a
        @_index = -1

        _ "adder",  "first three",   33
        _ "damud",  "first three",   44
        _ "deka",   "first three",   44
        _ "dora",   "second group",   3
        _ "gilius", "second group",   4
        _ "goah",   "second group",   7
        _ "guld",   "second group",   7
        _ "stern",  "third three",  333
        _ "trix",   "third three",  333
        _ "tyris",  "third three",  444

        @_index += 1
        @_eek.length == @_index || fail
      end

      def _ thing, cat, cost

        node = @_eek.fetch( @_index += 1 )
        h = node.box.h_
        _actual = [ node.get_filesystem_directory_entry_string, h.fetch( :category ), h.fetch( :cost ) ]
        _expected = [ thing, cat, cost ]
        NIL
      end

      shared_subject :__result_tree do
        operations_call_result_tuple.result
      end
    end
  end
end
