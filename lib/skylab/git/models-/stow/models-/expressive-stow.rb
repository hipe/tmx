module Skylab::Git

  class Models_::Stow

    class Models_::Expressive_Stow

      # a high level wrapper around almost every sibling node. we create
      # this in lieu of rolling it into the parent model so that the parent
      # model can be a [#sl-151] "pure", lighter-weight business entity,
      # delegating to this node the need to carry all the resorces and
      # modality-specific rendering knowledge.

      attr_reader(
        :resources,
      )

      def initialize * a, & oes_p

        @style_x, @stow, system_conduit, filesystem = a

        @resources = Resources___.new system_conduit, filesystem
        @on_event_selectively = oes_p
      end

      Resources___ = ::Struct.new :system_conduit, :filesystem

      def to_styled_stat_line_stream

        to_tree_stat.to_styled_line_stream
      end

      def to_non_styled_patch_line_stream

        to_tree_stat.to_non_styled_patch_line_stream
      end

      def to_styled_patch_line_stream

        to_tree_stat.to_styled_patch_line_stream
      end

      def to_item_stream
        to_tree_stat.to_item_stream
      end

      def to_tree_stat

        Models_::Tree_Stat.new(
          @stow.path,
          @resources,
          & @on_event_selectively
        )
      end

      def path
        @stow.path
      end
    end
  end
end
