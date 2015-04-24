module Skylab::Snag

  class Models_::Node

    class Actions::Create < Common_Action

      edit_entity_class(

                   :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :message
      )

      def produce_result
        resolve_node_collection_then_
      end

      def via_node_collection_

        bx = @argument_box

        @node_collection.edit :add, :node,
          :modifiers, bx,
          :message, bx.fetch( :message ),
          & handle_event_selectively
      end
    end
  end
end

# :+#tombstone: `list` method was original conception point of #doc-point [#sl-102])
