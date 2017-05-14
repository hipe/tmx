module Skylab::Snag

  class Models_::Tag

    Actions = ::Module.new

    class Actions::ToStream

      def definition ; [

        :description, -> y do
          y << 'list the tags for a given node.'
        end,

        :required, :property, :upstream_reference,
        :required, :property, :node_identifier,

      ] end

      def initialize
        extend ActionRelatedMethods_
        @_invocation_resources_ = yield
        init_action_ @_invocation_resources_
      end

      def execute
        if __resolve_node_only
          @_node_.to_tag_stream
        end
      end

      def __resolve_node_only  # (used to be part of NodeRelatedMethods)

        _ = @_invocation_resources_.call_snag_API__(
          :node, :to_stream,
          :identifier, @node_identifier,
          :upstream_reference, @upstream_reference,
          & _listener_ )

        _store_ :@_node_, _
      end
    end

    # ==

    class Actions::Create

      def definition ; [

        :description, -> y do
           y << "add a tag to a node."
        end,

        :flag, :property, :prepend,
        :property, :downstream_reference,
        :required, :property, :upstream_reference,
        :required, :property, :node_identifier,
        :required, :property, :tag
      ] end

      def initialize
        extend Home_::Models_::Node::NodeRelatedMethods, ActionRelatedMethods_
        init_action_ yield
        @prepend = nil  # #[#026]
      end

      def execute
        if resolve_node_collection_and_node_
          __via_node_collection_and_node
        end
      end

      def __via_node_collection_and_node

        ok = @_node_.edit(

          :assuming, :absent,

          ( @prepend ? :prepend : :append ),

          :tag, @tag,

          & _listener_ )

        persist_node_ if ok
      end
    end

    # ==

    class Actions::Delete

      def definition ; [

        :description, -> y do
          y << 'remove a tag from a node.'
        end,

        :property, :downstream_reference,
        :required, :property, :upstream_reference,
        :required, :property, :node_identifier,
        :required, :property, :tag
      ] end

      def initialize
        extend Home_::Models_::Node::NodeRelatedMethods, ActionRelatedMethods_
        init_action_ yield
        @downstream_reference = nil  # #[#026]
      end

      def execute
        if resolve_node_collection_and_node_
          __via_node_collection_and_node
        end
      end

      def __via_node_collection_and_node

        ok = @_node_.edit(
          :assuming, :present,
          :remove, :tag, @tag,
          & _listener_ )

        persist_node_ if ok
      end
    end

    # ==
    # ==
  end
end
