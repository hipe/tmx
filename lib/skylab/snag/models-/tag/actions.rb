module Skylab::Snag

  class Models_::Tag

    class Tag_Action__ < Brazen_::Model.common_action_class  # :+#stowaway, reopens
      Brazen_::Model.common_entity self
    end

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
        _ok = __resolve_node_only_
        _ok && __via_node
      end

      def __via_node
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

        _ok = __resolve_node_collection_and_node_
        _ok && __via_all
      end

      def __via_all

        h = @argument_box.h_

        _ok = @node.edit :append, :tag,

          :do_prepend, h[ :prepend ],

          :check_for_redundancy,

          :mixed, h[ :tag ],

          & handle_event_selectively

        _ok && __persist_
      end
    end

    class Tag_Action__

      def __resolve_node_only_

        _oes_p = handle_event_selectively

        node = @kernel.call_via_mutable_box :node, :to_stream,

          :identifier, @argument_box.remove( :node_identifier ),

          @argument_box,
          & _oes_p

        node and begin
          @node = node
          ACHIEVED_
        end
      end

      def __resolve_node_collection_and_node_

        _ok = __resolve_node_collection
        _ok && __via_collection_resolve_node
      end

      def __resolve_node_collection

        h = @argument_box.h_

        _silo = @kernel.silo :node_collection

        co = _silo.node_collection_via_upstream_identifier(
          h.fetch( :upstream_identifier ),
          & handle_event_selectively )

        co and begin
          @node_collection = co
          ACHIEVED_
        end
      end

      def __via_collection_resolve_node

        node = @node_collection.entity_via_intrinsic_key(
          @argument_box.fetch( :node_identifier ),
          & handle_event_selectively )

        node and begin
          @node = node
          ACHIEVED_
        end
      end

      def __persist_

        @node_collection.persist_entity(
          @argument_box,
          @node,
          & handle_event_selectively )
      end
    end
  end
end
