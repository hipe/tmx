module Skylab::TanMan

  class Models_::Node

    module Events__

      _ = Brazen_.event :Component_Already_Added

      Found_Existing_Node = _.prototype_with( :found_existing_node,

        :component_association, Here_,
        :did_mutate_document, false,
        :ok, nil
      )

      class Node_Statement_as_Component  # not an event - in support of them

        def initialize ns
          @_ns = ns
        end

        def description_under expag

          s = @_ns.label_or_node_id_normalized_string

          expag.calculate do
            lbl s
          end
        end
      end
    end
  end
end

# :+#tombstone: event prototypes for destroyed, not found
