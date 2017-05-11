module Skylab::TanMan

  module Models_::Graph

    class Actions::Sync

      class ExposedClient_for_Session___ < Common_::SimpleModel

        def initialize

          yield self

          dc = remove_instance_variable :@digraph_controller

          @_nodes_OB = Models_::Node::NodesOperatorBranchFacade_TM.new dc

          @_assocs_OB = Models_::Association::AssocOperatorBranchFacade_TM.new dc

          @_tick = 0  # how much work is done
        end

        attr_writer(
          :digraph_controller,
          :listener,
        )

        def receive_node id_s, label_s

          node = @_nodes_OB.lookup_softly_via_node_ID__IMPLEMENTATION_TWO__ id_s.intern

          if node  # #cov3.4 explains it all
            # __TODO_change_label_of_node label_s, node
            @listener.call :info, :found_existing_node do
              ::Kernel._COVER_ME__you_have_to_go_to_the_other_guy_or_redesign_this
            end
            ACHIEVED_
          else
            __add_node id_s, label_s
          end
        end

        def __add_node id_s, label_s

          @_tick += 1

          @_nodes_OB.node_by_ do |o|
            o.unsanitized_both id_s.intern, label_s
            o.verb_lemma_symbol = :create
            o.listener = @listener
          end
        end

        def receive_edge from_id_s, to_id_s

          @_tick += 1

          @_assocs_OB.touch_association_by_ do |o|

            o.from_and_to_IDs from_id_s.intern, to_id_s.intern
            o.listener = @listener
          end
        end

        def receive_finish

          # by resulting in the below we particicpate in telling the
          # caller this information so that we can skip needlessly
          # writing documentst that haven't changed.

          if @_tick.zero?
            DID_NO_WORK_
          else
            DID_WORK_
          end
        end

        # ==
        # ==
      end
    end
  end
end
