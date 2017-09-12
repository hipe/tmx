module Skylab::Snag

  class Models_::Node

    class Actions::Close

      def definition ; [

        :description, -> y do
          'close a node (remove tag #open and add tag #done)'
        end,

        :property, :downstream_reference,
        :required, :property, :upstream_reference,
        :required, :property, :node_identifier,
      ] end

      def initialize
        extend NodeRelatedMethods, ActionRelatedMethods_
        init_action_ yield
        @downstream_reference = nil  # #[#026]
      end

      def execute
        if resolve_node_collection_and_node_
          __via_node_collection_and_node
        end
      end

      def __via_node_collection_and_node

        _ok = @_node_.edit(

          :if, :present,
            :remove, :tag, :open,

          :if, :not, :present,
            :prepend, :tag, :done,

          & _listener_ )

        _ok && persist_node_
      end

      Actions = nil

      # ==
      # ==
    end
  end
end
