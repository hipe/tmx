module Skylab::TanMan

  module Models_::DotFile  # cannot be a model subclass because of the
    # combinaton of facts that a) treetop allows grammar to be nested within
    # ruby modules but not classes and b) we want to nest our treetop
    # grammars under the relevant model node (this one).

    DEFAULT_EXTENSION = '.dot'.freeze

    class DigraphSession_via_THESE < Common_::MagneticBySimpleModel  # 1x + #testpoint

      # read :[#021] "the digraph session architecture" which is exactly this.

      # #open [#098] once we understand our requirements, we may further
      # abstract lock-related logic up & out into the byte stream reference API

      def initialize
        @_mutex_for_RDWR_vs_RDONLY = nil
        @__mutex_for_BSR = nil
        super
      end

      def be_read_write_not_read_only_
        remove_instance_variable :@_mutex_for_RDWR_vs_RDONLY
        @_is_read_write_not_read_only = :_TRUE ; nil
      end

      def be_read_only_not_read_write_
        remove_instance_variable :@_mutex_for_RDWR_vs_RDONLY
        @_is_read_write_not_read_only = :_FALSE ; nil
      end

      def immutable_workspace= ws
        _will_solve_BSR_via :__resolve_open_streams_via_immutable_workspace
        @immutable_workspace = ws
      end

      def qualified_knownness_box= bx
        _will_solve_BSR_via :__resolve_open_streams_via_qualified_knownness_box
        @qualified_knownness_box = bx
      end

      def two_byte_stream_references__ bsr, bsr_
        _will_solve_BSR_via :__resolve_open_streams_via_unsanitized_BSR_AND_ETC
        @__OUTPUT_STREAM_REFERENCE = bsr_
        @byte_stream_reference = bsr
        NIL
      end

      def byte_stream_reference= bsr
        _will_solve_BSR_via :__resolve_open_streams_via_unsanitized_BSR
        @byte_stream_reference = bsr
      end

      def _will_solve_BSR_via m
        remove_instance_variable :@__mutex_for_BSR
        @__resolve_open_streams = m ; nil
      end

      def session_by & p
        @__pass_document_controller_into_this_and_use_result = p ; nil
      end

      attr_writer(
        :is_dry_run,
        :listener,
        :microservice_invocation,
      )

      def execute
        if __resolve_open_streams  # (B)
          ok = __resolve_generated_grammar_dir_path  # (C)
          ok &&= __resolve_graph_sexp_via_everything  # (D)
          ok && __init_document_controller_via_graph_sexp  # (E)
          if ok
            x = __yield_document_controller_to_user_and_maybe_persist  # (F)
          else
            x = ok
          end
          __close_as_necessary  # (G)
          x
        end
      end

      # -- G:

      def __close_as_necessary

        @_open_streams.each do |obs|
          obs.is_lockable_and_locked || next
          obs.close_stream_and_release_lock_  # :#spot3.1
        end

        remove_instance_variable :@_open_streams
        NIL
      end

      # -- F:

      def __yield_document_controller_to_user_and_maybe_persist

        x = @__pass_document_controller_into_this_and_use_result[ @_DC ]

        if x
          _user_call_succeeded = true
        elsif ! x.nil?
          self._COVER_ME__meaningful_false__
        end

        if _user_call_succeeded
          if _is_read_write_not_read_only

            _yes = if x.respond_to? :_DO_WRITE_COLLECTION_
              x._DO_WRITE_COLLECTION_
            else
              ACHIEVED_  # node silo, at writing
            end

            if _yes
              bytes = __persist
              if bytes
                DidWrite___[ x, bytes ]
              end
            else
              # see #archive-A.3 for when we emitted here
              DidNotWrite___[ x ]
            end
          else
            x
          end
        else
          x  # nil
        end
      end

      DidWrite___ = ::Struct.new :user_value, :bytes do
        def did_write
          TRUE
        end
      end

      DidNotWrite___ = ::Struct.new :user_value do
        def did_write
          FALSE
        end
      end

      def __persist  # was `persist_into_byte_downstream_reference`

        # (whether we have one two-way stream or two streams.. same as #here3)

        _bdr = @_open_streams.last.sanitized_byte_stream_reference

        _is_dry = remove_instance_variable :@is_dry_run

        _bytes = @_DC.write_and_emit_by_ do |o|
          o.byte_stream_reference = _bdr
          o.is_dry_run = _is_dry
          o.listener = @listener
        end

        _bytes  # hi. #todo
      end

      # -- E:

      def __init_document_controller_via_graph_sexp

        # (it's a bit of a coin-toss whether to associate the upstream or
        # the downstream reference with the document, and
        # #open [#007.E] probably a smell - why do we need to assoc a
        # BSR with a document controller at all?)

        _use_bsr = @_open_streams.first.sanitized_byte_stream_reference

        @_DC = Here_::DocumentController___.define do |o|
          o.byte_stream_reference = _use_bsr
          o.graph_sexp = remove_instance_variable :@__graph_sexp
        end

        NIL
      end

      # -- D:

      def __resolve_graph_sexp_via_everything

        # (whether we have one ONE-way stream, one TWO-way stream or two
        #  streams, all we need to know is that the first (leftmost) one
        #  is the upstream. :#here3)

        _bur = @_open_streams.first.sanitized_byte_stream_reference

        _path = remove_instance_variable :@__generated_grammar_dir_path

        _gs = Here_::ParseTree_via_ByteUpstreamReference.via(

          :byte_upstream_reference, _bur,
          :generated_grammar_dir_path, _path,

          & @listener )

        _store :@__graph_sexp, _gs
      end

      # -- C:

      def __resolve_generated_grammar_dir_path

        _ = @microservice_invocation.generated_grammar_dir__
        _store :@__generated_grammar_dir_path, _
      end

      # -- B:

      def __resolve_open_streams
        send remove_instance_variable :@__resolve_open_streams
      end

      # ~

      def __resolve_open_streams_via_immutable_workspace

        if __resolve_digraph_path_via_workspace

          __resolve_open_streams_via_digraph_path
        end
      end

      def __resolve_open_streams_via_digraph_path

        _path = remove_instance_variable :@__digraph_path

        _qkn = Common_::QualifiedKnownKnown.via_value_and_symbol(
          _path, :input_path )  # name is important, must accord with [#ba-062]

        _resolve_open_streams_by do |o|
          o.for_qualified_knownness_and_direction__ _qkn, :input
        end
      end

      def __resolve_digraph_path_via_workspace

        _ws = remove_instance_variable :@immutable_workspace

        _ = _ws.procure_component_by_ do |o|
          o.assigment :path, :digraph
          o.will_be_asset_path
          o.would_invite_by { [ :graph, :use ] }
          o.listener = @listener
        end

        _store :@__digraph_path, _
      end

      # ~

      def __resolve_open_streams_via_qualified_knownness_box

        if __resolve_tuple_via_QK_box

          _a = remove_instance_variable( :@__tuple ).byte_stream_reference_qualified_knownness_array

          _resolve_open_streams_by do |o|
            o.for_one_or_two_QKs__ _a
          end
        end
      end

      def __resolve_tuple_via_QK_box

        if _is_read_write_not_read_only  # :#spot2.1 (important)
          these = [ :input, :output ]
        else
          these = [ :input ]  # #cov3.1
        end

        _bx = remove_instance_variable :@qualified_knownness_box

        _ = Mags_[]::ByteStreamReferences_via_Request.call_by do |o|

          o.qualified_knownness_box = _bx
          o.will_solve_for( * these )
          o.will_enforce_minimum
          o.listener = @listener
        end

        _store :@__tuple, _
      end

      # ~

      def __resolve_open_streams_via_unsanitized_BSR_AND_ETC

        _bsr = remove_instance_variable :@byte_stream_reference
        _bsr_ = remove_instance_variable :@__OUTPUT_STREAM_REFERENCE

        _resolve_open_streams_by do |o|
          o.these_two_byte_stream_references__ _bsr, _bsr_
        end
      end

      def __resolve_open_streams_via_unsanitized_BSR

        # this is for when we were passed a single BSR

        _bsr = remove_instance_variable :@byte_stream_reference
        _resolve_open_streams_by do |o|
          o.only_this_byte_stream_reference__ _bsr
        end
      end

      # -- A: support

      def _resolve_open_streams_by

        _ = Mags_[]::OpenByteStreams_via_Request.call_by do |o|  # 1x
          yield o
          o.is_read_write_not_read_only = _is_read_write_not_read_only
          o.filesystem = __filesystem
          o.listener = @listener
        end

        _store :@_open_streams, _
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def _is_read_write_not_read_only
        send @_is_read_write_not_read_only
      end

      def _FALSE
        FALSE
      end

      def _TRUE
        TRUE
      end

      def __filesystem
        @microservice_invocation.invocation_resources.filesystem
      end
    end

    # ==

    Here_ = self

    # ==
    # ==
  end
end
# #archive-A.3: got rid of the event that was emitted on no write
# #history-A.2: moved "persist dotfile" out of file to other file
# #history-A: spike of main magnetic (locked file session) back into here
