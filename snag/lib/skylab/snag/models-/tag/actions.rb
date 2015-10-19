module Skylab::Snag

  class Models_::Tag

    Tag_Action__ = Home_::Models_::Node::Common_Action_  # stowaway

    Actions = ::Module.new

    class Actions::To_Stream < Tag_Action__

      edit_entity_class(

        :desc, -> y do
          y << 'list the tags for a given node.'
        end,

        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier
      )

      def produce_result
        resolve_node_only_then_
      end

      def via_node_only_
        @node.to_tag_stream
      end
    end

    class Actions::Create < Tag_Action__

      edit_entity_class(

        :desc, -> y do
           y << "add a tag to a node."
        end,

        :flag, :property, :prepend,
        :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier,
        :required, :property, :tag
      )

      def produce_result
        resolve_node_collection_and_node_then_
      end

      def via_node_collection_and_node_

        h = @argument_box.h_

        _ok = @node.edit(

          :assuming, :absent,

          ( h[ :prepend ] ? :prepend : :append ),

          :tag, h[ :tag ],

          & handle_event_selectively )

        _ok && persist_node_
      end
    end

    class Actions::Delete < Tag_Action__

      edit_entity_class(

        :desc, -> y do
          y << 'remove a tag from a node.'
        end,

        :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier,
        :required, :property, :tag
      )

      def produce_result
        resolve_node_collection_and_node_then_
      end

      def via_node_collection_and_node_

        _h = @argument_box.h_

        _ok = @node.edit(
          :assuming, :present,
          :remove, :tag, _h.fetch( :tag ),
          & handle_event_selectively )

        _ok && persist_node_
      end
    end
  end
end
