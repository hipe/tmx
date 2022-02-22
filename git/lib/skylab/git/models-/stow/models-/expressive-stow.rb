module Skylab::Git

  class Models_::Stow

    class Models_::ExpressiveStow  # 1x

      # a high level wrapper around almost every sibling node. we create
      # this in lieu of rolling it into the parent model so that the parent
      # model can be a [#sl-151] "pure", lighter-weight business entity,
      # delegating to this node the need to carry all the resorces and
      # modality-specific rendering knowledge.

      def initialize style_x, stow, rsc, & p
        @listener = p
        @resources = rsc
        @style_x = style_x
        @stow = stow
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
        Models_::TreeStat.new(
          @stow.path,
          @resources,
          & @listener
        )
      end

      def path
        @stow.path
      end
    end
  end
end
