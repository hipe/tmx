module Skylab::GitViz

  module CLI

    class Actions__::Hist_Tree < Action_

      def invoke_with_iambic x_a
        @tree = invoke_API_with_iambic x_a
        @tree and execute
      end
    private
      def execute
        es = first_pass
        es or second_pass
      end
      def first_pass
        scn = @tree.get_traversal_scanner :glyphset_x, :narrow  # wide or narrow
        prcss_root scn.gets
        row_a = [] ; max = 0
        while (( card = scn.gets ))
          n = card.node
          _line_node_slug = if n.is_branch
            n.slug
          else
            n.slug
          end
          row = Row__.new card.prefix[], n.is_leaf,
            _line_node_slug, n.repo_node
          d = row.file_column_string_length
          max < d and max = d
          row_a << row
        end
        @row_a = row_a ; @file_column_string_width = max
        nil
      end
      def prcss_root root_card
        @heatmap_renderer = Heatmap_Renderer__.
          new root_card.node.commitpoint_manifest ; nil
      end
      def second_pass
        fmt = "%-#{ @file_column_string_width }s  #{ TALL_PIPE__ }"
        @row_a.each do |row|
          _heatmap = if row.is_leaf
            render_heatmap_string row
          end
          _s = "#{ fmt % "#{ row.glyph_s }#{ row.slug_s }" }#{ _heatmap }"
          emit_payload_line _s
        end
        SUCCESS_EXIT_STATUS__
      end
      def render_heatmap_string row
        @heatmap_renderer.render_string_for_row row
      end

      class Heatmap_Renderer__

        def initialize commitpoint_manifest
          p = Heatmap_Render__.new
          p.string = ' ' * commitpoint_manifest.commitpoint_count
          @render_prototype = p ; nil
        end

        def render_string_for_row row
          @render_prototype.dupe_for_row( row ).execute
        end
      end

      class Heatmap_Render__

        attr_accessor :row, :string

        def initialize_copy otr
          @string = otr.string.dup ; nil
        end

        def dupe_for_row row
          otr = dup
          otr.row = row
          otr
        end

        def execute
          @scn = @row.repo_node.get_commitpoint_scanner
          while (( cp = @scn.gets ))
            _index = cp.commitpoint_index
            @string[ _index ] = BULLET__
          end
          @string
        end

        BULLET__ = '•'.freeze
      end

      class Row__
        def initialize glyph_s, is_leaf, slug_s, repo_node
          @glyph_s = glyph_s ; @is_leaf = is_leaf
          @repo_node = repo_node ; @slug_s = slug_s
        end
        attr_reader :glyph_s, :is_leaf, :repo_node, :slug_s
        def file_column_string_length
          @glyph_s.length + @slug_s.length
        end
      end

      SUCCESS_EXIT_STATUS__ = 0
      TALL_PIPE__ = '│'.freeze
    end
  end
end
