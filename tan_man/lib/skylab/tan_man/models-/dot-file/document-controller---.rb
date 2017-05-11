module Skylab::TanMan

  module Models_::DotFile

    class DocumentController___ < Common_::SimpleModel

      # ([#009] is where notes for this would go. currently only one short, ancient note there.)

      attr_writer(
        :byte_stream_reference,  # just for description
        :graph_sexp,
      )

      # -- write

      def insert_stmt_before_stmt new, least_greater_neighbor
        insert_stmt new, least_greater_neighbor
      end

      def insert_stmt new, new_before_this=nil  # :[#here.B]

        g = @graph_sexp

        if ! g.stmt_list
          g.stmt_list = __empty_stmt_list
        end

        if ! g.stmt_list.prototype_
          st = g.stmt_list.to_element_stream_  # used to be `length_exceeds( 1 )`
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
          _x  # you're on your own if you use this..
        else
          UNABLE_
        end
      end

      # -- read (sic)

      def write_and_emit_by_

        _bytes = PersistDotfile___.call_by do |o|
          yield o
          o.graph_sexp = @graph_sexp
        end

        _bytes  # hi.
      end

      def write_bytes_into y
        @graph_sexp.write_bytes_into y
      end

      def description_under expag
        @byte_stream_reference.description_under expag
      end

      attr_reader(
        :graph_sexp,
      )

      # -- finish

      def close_document_controller_permanantly__
        remove_instance_variable :@byte_stream_reference
        remove_instance_variable :@graph_sexp
        remove_instance_variable :@listener
        freeze
      end

      # ==

      class PersistDotfile___ < Common_::MagneticBySimpleModel

        # (ideally we like these nodes out of the main flow but this is anemic.)
        # (#[#sy-032.2] tracks events like these (3 total known at writing))
        # (was `PersistDotFile_via_ByteDownstreamReference_and_GraphSexp`)

        attr_writer(
          :byte_stream_reference,
          :graph_sexp,
          :is_dry_run,
          :listener,
        )

        def execute

          y = if @is_dry_run
            Home_.lib_.system_lib::IO::DRY_STUB
          else
            @byte_stream_reference.to_minimal_yielder_for_receiving_lines
          end

          bytes = @graph_sexp.write_bytes_into y

          # don't close here.. close at #spot3.1

          @listener.call :success, :wrote_resource do
            __build_event bytes
          end

          bytes
        end

        def __build_event bytes

          Common_::Event.inline_OK_with(
            :wrote_resource,
            :byte_downstream_reference, @byte_stream_reference,
            :bytes, bytes,
            :was_dry_run, @is_dry_run,
            :is_completion, true,
          ) do  |y, o|

            _document = o.byte_downstream_reference.description_under self

            y << "updated #{ _document } #{
              }(#{ o.bytes }#{ ' dry' if o.was_dry_run } bytes)"
          end
        end
      end

      # ==
      # ==
    end
  end
end
# #history-A.2: re-gained file writing
# #tombstone-B: file writing x
# #tombstone-A: `length_exceeds` on stream
