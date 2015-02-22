module Skylab::TanMan

  class Models_::Graph

    class Sync_

      class Session___

        def initialize dc, kr, & oes_p

          nc = kr.silo( :node ).
            node_collection_controller_via_document_controller(
              dc, & oes_p )  # :+#uncovered-failpoint

          bx = Callback_::Box.new
          bx.add :node, nc
          bx.add :dot_file, dc

          @ac = kr.silo( :association ).
            association_collection_controller_via_preconditions(
              bx, & oes_p )

          @dc = dc
          @nc = nc
          @on_event_selectively = oes_p
        end

        def receive_node id_s, label_s

          node = @nc.retrieve_any_node_with_id id_s
          if node
            __TODO_change_label_of_node label_s, node
          else
            __add_node id_s, label_s
          end
        end

        def __add_node id_s, label_s
          @nc.add_node_via_id_and_label id_s, label_s and ACHIEVED_
        end

        def receive_edge from_id_s, to_id_s
          @ac.touch_association_via_IDs(
            from_id_s.intern,
            to_id_s.intern, & @on_event_selectively ) and ACHIEVED_
        end

        def receive_finish

          # per [#001] there is nothing more to do.
          # it's not within our scope to persist the graph.

          ACHIEVED_
        end
      end
    end
  end
end
