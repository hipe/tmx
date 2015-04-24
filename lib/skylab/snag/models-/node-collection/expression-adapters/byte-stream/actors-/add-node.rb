module Skylab::Snag

  class Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      class Actors_::Add_node

        Callback_::Actor.call self, :properties, :bx, :node, :collection

        def execute

          BS_::Sessions_::Rewrite_Stream_End_to_End.new(

            @bx, @node, @collection, & @on_event_selectively

          ).session do | o |

            _tree = __build_tree_of_all_identifiers o.entity_upstream

            id = __find_first_available_identifier_in_tree _tree

            o.reset_the_entity_upstream

            @node.edit :receive, :identifier, :object, id, & @on_event_selectively

            o.write_each_node_whose_identifier_is_greater_than_that_of_subject

            o.write_the_new_node
            o.write_any_floating_node
            o.write_the_remaining_nodes

          end
        end

        def __build_tree_of_all_identifiers node_st

          _Tree = Snag_.lib_.basic::Tree

          _Big_Tree = _Tree.mutable_node
          _Frugal_Tree = _Tree.frugal_node

          # (in hindsight, using "frugal tree" here may have no gain: these
          # these nodes are always branches, never leaves; nonetheless we
          # leave it in as :+#grease)

          tree = _Big_Tree.new

          begin
            node = node_st.gets
            node or break

            id = node.ID

            _tree_ = tree.touch id.to_i do

              _Frugal_Tree.new id.to_i
            end

            sfx = id.suffix

            # (in both below cases, if there are effectively duplicate ID's,
            #  only the first one is counted; which is all that is necessary)

            if sfx
              self._COVER_ME
              _tree_.touch sfx do
                id
              end
            else
              _tree_.touch NIL_ do
                id
              end
            end

            redo
          end while nil

          tree
        end

        def __find_first_available_identifier_in_tree tree

          h = tree.h_
          int = 1

          begin
            if h.key? int
              int += 1
              redo
            end
            break
          end while nil

          Snag_::Models_::Node_Identifier.new_via_integer int
        end
      end
    end
  end
end
