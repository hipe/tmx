module Skylab::Snag

  class Models_::Node

    Home_._NO_MORE_COMMON_ACTION
    class Actions::Close < Common_Action_

      edit_entity_class(

        :branch_description, -> y do
          'close a node (remove tag #open and add tag #done)'
        end,

        :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier
      )

      def execute
        if resolve_node_collection_and_node_
          __via_node_collection_and_node
        end
      end

      def __via_node_collection_and_node

        _ok = @node.edit(

          :if, :present,
            :remove, :tag, :open,

          :if, :not, :present,
            :prepend, :tag, :done,

          & _listener_ )

        _ok && persist_node_
      end
    end
  end
end
