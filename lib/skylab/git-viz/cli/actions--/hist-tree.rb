module Skylab::GitViz

  module CLI

    class Actions__::Hist_Tree < Action_

      def invoke_with_iambic x_a
        @x_a = x_a
        prepare_VCS_resources
        @tree = invoke_API_with_iambic @x_a
        @tree and render_tree
      end

    private

      def prepare_VCS_resources  # continuation of [#006]:#storypoint-40
        @do_use_mocks = :do_use_mocks == @x_a.first && @x_a.shift && true
        @pathname = :pathname == @x_a.first && begin @x_a.shift ; @x_a.shift end
        @x_a.unshift :VCS_adapters_module, GitViz::VCS_Adapters_
        if @do_use_mocks
          prepare_VCS_resouces_for_mocks
        else
          self._DO_IT_LIVE_
        end
      end

      def prepare_VCS_resouces_for_mocks
        fixtures_mod = GitViz::TestSupport::VCS_Adapters_::Git::Fixtures
        _mock_FS = GitViz::Test_Lib_::Mock_FS::In_module[ fixtures_mod ]
        _mock_pn = _mock_FS.touch_pn @pathname.to_path
        @x_a.push :pathname, _mock_pn
        _mock_sc = GitViz::Test_Lib_::Mock_System::In_module[ fixtures_mod ]
        @x_a.unshift :system_conduit, _mock_sc
      end

      def repo_root_not_found_error_string_from_VCS str
        emit_error_line "(info: #{ str })"
      end

      def info_string_omitting_informational_commitpoint_from_VCS str
        emit_info_line str
      end

      def render_tree
        es = rndr_first_pass
        es or rndr_second_pass
      end

      def rndr_first_pass
        scn = @tree.get_traversal_scanner :glyphset_x, :narrow  # wide or narrow
        prcss_root scn.gets
        row_a = [] ; max = 0
        while (( card = scn.gets ))
          n = card.node
          _line_node_slug = if n.is_branch
            n.slug  # e.g maybe colorize this one
          else
            n.slug
          end
          row = Row__.new card.prefix[], n.is_leaf,
            _line_node_slug, n.repo_trail
          d = row.file_column_string_length
          max < d and max = d
          row_a << row
        end
        @row_a = row_a ; @file_column_string_width = max ; nil
      end

      def prcss_root root_card
        _cpm = root_card.node.some_commitpoint_manifest
        @heatmap_renderer = Heatmap_Renderer__.new _cpm ; nil
      end

      def rndr_second_pass
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
          @render_prototype.dupe_for_row( row ).render_heatmap_row
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

        def render_heatmap_row
          @scn = @row.repo_trail.get_filediff_scanner
          while (( fd = @scn.gets ))
            _index = fd.commitpoint_index
            @string[ _index ] = BULLET__
          end
          @string
        end

        BULLET__ = '•'.freeze
      end

      class Row__
        def initialize glyph_s, is_leaf, slug_s, repo_trail
          @glyph_s = glyph_s ; @is_leaf = is_leaf
          @repo_trail = repo_trail ; @slug_s = slug_s
        end
        attr_reader :glyph_s, :is_leaf, :repo_trail, :slug_s
        def file_column_string_length
          @glyph_s.length + @slug_s.length
        end
      end

      SUCCESS_EXIT_STATUS__ = 0
      TALL_PIPE__ = '│'.freeze
    end
  end
end
