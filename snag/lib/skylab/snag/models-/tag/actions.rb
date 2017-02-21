module Skylab::Snag

  class Models_::Tag

    Actions = ::Module.new

    class Actions::ToStream

      def definition ; [

        :branch_description, -> y do
          y << 'list the tags for a given node.'
        end,

        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier,

      ] end

      def initialize
        self._README__this_requires_this_one_essential_feature__
        # this looked good, but it wants to call to the selfsame API
        extend ActionMethodsRelatedToTags_
        o = yield
        init_action_ o
      end

      def execute
        if resolve_node_only__
          @_node_.to_tag_stream
        end
      end
    end

    # ==

    class Actions::Create

      def definition ; [

        :branch_description, -> y do
           y << "add a tag to a node."
        end,

        :flag, :property, :prepend,
        :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier,
        :required, :property, :tag
      ] end

      def execute
        extend ActionMethodsRelatedToTags_
        if resolve_node_collection_and_node_
          __via_node_collection_and_node
        end
      end

      def __via_node_collection_and_node

        self._NO_MORE_ARGUMENT_BOX
        h = @argument_box.h_

        _ok = @node.edit(

          :assuming, :absent,

          ( h[ :prepend ] ? :prepend : :append ),

          :tag, h[ :tag ],

          & _listener_ )

        _ok && persist_node_
      end
    end

    # ==

    class Actions::Delete

      def definition ; [

        :branch_description, -> y do
          y << 'remove a tag from a node.'
        end,

        :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier,
        :required, :property, :tag
      ] end

      def execute
        extend ActionMethodsRelatedToTags_
        if resolve_node_collection_and_node_
          __via_node_collection_and_node
        end
      end

      def __via_node_collection_and_node

        self._NO_MORE_ARGUMENT_BOX
        _h = @argument_box.h_

        _ok = @node.edit(
          :assuming, :present,
          :remove, :tag, _h.fetch( :tag ),
          & _listener_ )

        _ok && persist_node_
      end
    end

    # ==
    # ==
  end
end
