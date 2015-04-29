module Skylab::Snag

  class Models_::Node

    class Actions::Close < Common_Action

      edit_entity_class(

        :desc, -> y do
          'close a node (remove tag #open and add tag #done)'
        end,

        :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier
      )

      def produce_result
        resolve_node_collection_and_node_then_
      end

      def via_node_collection_and_node_

        _ok = @node.edit(

          :if_present,
            :remove, :tag, :open,

          :unless_present,
            :prepend, :tag, :done,

          & handle_event_selectively )

        _ok && persist_node_
      end
    end
  end
end
