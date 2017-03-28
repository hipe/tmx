module Skylab::TanMan

  module Models_::DotFile

    class DocumentController___ < Common_::SimpleModel

      # ([#009] is where notes for this would go. currently only one short, ancient note there.)

        # we encapsulate the byte upstream ID into the controller because
        # every document has exactly one BUID. however the same relationship
        # does not hold with byte downstream ID's so they are passed as args.

      attr_writer(
        :byte_upstream_reference,
        :graph_sexp,
        :invocation,
        :listener,
      )

      # -- "read"

      def persist_into_byte_downstream_reference id, * x_a, & oes_p  # [ :is_try, true ]

        Here_::Magnetics_::PersistDotFile_via_ByteDownstreamReference_and_GraphSexp.new(
          id, @graph_sexp, x_a, & oes_p ).execute
      end

      def description_under expag
        @byte_upstream_reference.description_under expag
      end

      def at_graph_sexp i
        @graph_sexp.send i
      end

      def unparse_into y
        @graph_sexp.unparse_into y
      end

      # ~ mutators

      def insert_stmt_before_stmt new, least_greater_neighbor
        insert_stmt new, least_greater_neighbor
      end

      def insert_stmt new, new_before_this=nil  # :[#here.B]

        g = @graph_sexp

        if ! g.stmt_list
          g.stmt_list = __empty_stmt_list
        end

        if ! g.stmt_list.prototype_
          st = g.stmt_list.to_node_stream_  # used to be `length_exceeds( 1 )`
          _one = st.gets
          if _one
            _length_exceeds_one = st.gets
          end
          unless _length_exceeds_one
            g.stmt_list.prototype_ = _sl_proto
          end
        end

        if new_before_this
          g.stmt_list.insert_item_before_item_ new, new_before_this
        else
          g.stmt_list.append_item_ new
        end
      end

      def __empty_stmt_list
        _sl_proto.duplicate_except_ :stmt, :tail
      end

      def _sl_proto  # assumes static grammar
        Memoized_SL_proto___[] || Memoize_SL_proto___[ @graph_sexp.class ]
      end

      -> do
        x = nil
        Memoized_SL_proto___ = -> do
          x
        end
        Memoize_SL_proto___ = -> parser do
          x = parser.parse :stmt_list, "xyzzy_1\nxyzzy_2"
          x.freeze
          x
        end
      end.call

      def destroy_stmt stmt
        if @graph_sexp.stmt_list
          _x = @graph_sexp.stmt_list.remove_item_ stmt
          _x ? ACHIEVED_ : UNABLE_  # we mean to destroy
        else
          UNABLE_
        end
      end

      attr_reader(
        :graph_sexp,
      )

      def provide_action_precondition _id, _g
        self
      end

      # ==
      # ==
    end
  end
end
# #tombstone-A: `length_exceeds` on stream
