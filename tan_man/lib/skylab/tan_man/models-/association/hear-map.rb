module Skylab::TanMan

  class Models_::Association

    module Hear_Map

      module Definitions

        class Touch_Nodes_And_Create_Association

          def after
            # nothing.
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'depends',
                :keyword, 'on',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard hrd, & oes_p

            pt = hrd.parse_tree

            Touch_Node_and_Create_Association__.new(
              pt.fetch( 0 ).join( SPACE_ ),
              pt.fetch( 3 ).join( SPACE_ ),
              hrd.qualified_knownness_box,
              hrd.kernel, & oes_p ).bound_call
          end
        end

        class Delete_Association

          def after
            [ :meaning, :create_association ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'does',
                :keyword, 'not',
                :keyword, 'depend',
                :keyword, 'on',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard hrd
            self._DO_ME
          end
        end
      end

      class Touch_Node_and_Create_Association__

        def initialize * a, & oes_p
          @src_lbl_s, @dst_lbl_s, @qualified_knownness_box, @kernel = a
          @did_mutate = false
          @did_mutate_filter = -> * sym_a, & ev_p do
            ev = ev_p[]
            if ev.ok && ev.did_mutate_document
              @did_mutate = true
            end
            oes_p.call( * sym_a ) do
              ev
            end
          end
          @on_event_selectively = oes_p
        end

        def bound_call

          ok = __resolve_document_controller
          ok &&= __via_document_controller_maybe_touch_nodes
          ok &&= __via_document_controller_and_nodes_touch_association
          ok &&= __maybe_persist
          if ok
            Common_::BoundCall.via_value ok
          else
            ok
          end
        end

        def __resolve_document_controller

          _dc = Models_::DotFile::DigraphSession_via_THESE.call_by do |o|
            ::Kernel._THIS_CHANGED__but_it_can_be_easy__
            o.qualified_knownness_box = @qualified_knownness_box
            o.listener = @on_event_selectively
          end

          _store :@dc, _dc
        end

        def __via_document_controller_maybe_touch_nodes

          @nodes_controller = @kernel.silo( :node ).  # used 2x later
            node_collection_controller_via_document_controller(
              @dc, & @did_mutate_filter )

          # because the association silo alone won't do the hacky magic for this

          if @dc.graph_sexp.stmt_list.nil?
            __via_document_controller_DO_touch_nodes
          else
            ACHIEVED_
          end
        end

        def __via_document_controller_DO_touch_nodes

          nc = @nodes_controller
          sn = nc.touch_node_via_label @src_lbl_s
          sn and dn = nc.touch_node_via_label( @dst_lbl_s )
          sn and dn and begin
            @src_node_stmt = sn
            @dst_node_stmt = dn
            ACHIEVED_
          end
        end

        def __via_document_controller_and_nodes_touch_association

          bx = @nodes_controller.to_preconditions_plus_self__

          ac = @kernel.silo( :association ).
            association_collection_controller_via_preconditions(
              bx,
              & @on_event_selectively )

          _asc = ac.touch_association_via_node_labels(
            @src_lbl_s, # @src_node_stmt.label,
            @dst_lbl_s, # @dst_node_stmt.label,
            & @did_mutate_filter )

          _asc and ACHIEVED_
        end

        def __maybe_persist

          if @did_mutate
            __do_persist
          else
            ACHIEVED_  # assume that 3 events were emitted
          end
        end

        def __do_persist

          ::Kernel._THIS_CHANGED__but_it_can_be_easy__
          o = Home_::DocumentMagnetics_::ByteStreamReference_via_Request
          o = Home_::Model_::DocumentEntity::ByteStreamIdentifier_via.new(
            @kernel, & @on_event_selectively )

          o.for_model Here_

          o.against_qualified_knownness_box @qualified_knownness_box

          id = o.solve_for :output

          id and begin

            if :path == id.shape_symbol && DASH_ == id.path

              id = Brazen_::Collection::ByteDownstreamReference.via_open_IO(
                @qualified_knownness_box.fetch( :stdout ).value_x )
            end

            __persist_into_byte_downstream id
          end
        end

        def __persist_into_byte_downstream id

          arg = @qualified_knownness_box[ :dry_run ]
          if arg
            is_dry = arg.value_x
          end

          @dc.persist_into_byte_downstream_reference id,
            :is_dry, is_dry,
            & @on_event_selectively
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end
    end
  end
end
# ( a note for #!posterity, the old treemap versions of some of these definitions were in what is now models-/hear-front/core.rb )
