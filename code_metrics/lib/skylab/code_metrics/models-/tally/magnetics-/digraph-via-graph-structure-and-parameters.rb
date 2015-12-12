module Skylab::CodeMetrics

  class Models_::Tally

    class Magnetics_::Digraph_via_Graph_Structure_and_Parameters

      attr_writer(

        :features_section_label,
        :bucket_tree_section_label,
        :document_label,

        # --

        :graph_structure,
        :upstream_line_yielder,
      )

      def initialize
        @features_section_label = FEATURES_SECTION_LABEL___
        @bucket_tree_section_label = nil
      end

      FEATURES_SECTION_LABEL___ = 'Features'

      def execute

        @_y = __build_line_yielder
        @_y << "digraph G {"
        _blank_line
        _indent

        s = @document_label
        if s
          @_y << "label=\"#{ _quot s }\""
        end

        _blank_line
        __express_feature_listing
        _blank_line
        __express_tree
        _blank_line
        __express_occurrences
        _dedent
        @_y << CLOSE_CURLY__
        __done
      end

      def __express_tree

        @_last_feature_cluster_number = 0

        @_y << "subgraph cluster_feature_tree {"
        _indent

        s = @bucket_tree_section_label
        if s
          _ = _quot s
          @_y << "label=\"#{ _ }\""
        end

        _blank_line

        @_y << "node [style=filled shape=rect]"
        _blank_line

        _t = @graph_structure.bucket_tree

        __express_tree_recursive _t

        _dedent
        @_y << CLOSE_CURLY__

        NIL_
      end

      def __express_tree_recursive t  # assume nonzero children

        _d = ( @_last_feature_cluster_number += 1 )

        @_y << "subgraph cluster_feature_subtree_#{ _d } {"

        _indent

        slug_a = []
        x = t.slug
        if x  # topmost slug is nil. first slug for abspath is empty string.
          slug_a.push x
        end

        begin
          # if the current tree has only one child..
          t_ = t.any_only_child
          t_ or break

          # if that only child is itself a leaf, stop what you are doing..
          if t_.length.zero?
            break
          end

          # othewise, instead of giving this node its own frame, squash it
          slug_a.push t_.slug
          t = t_
          redo
        end while nil

        _label = _quot slug_a.join ::File::SEPARATOR

        @_y << "label=\"#{ _label }\""

        _blank_line

        ___express_children t

        _dedent

        @_y << CLOSE_CURLY__

        NIL_
      end

      def ___express_children t

        # any leaves first, then recurse into any branches..

        st = t.to_child_stream

        branches = nil

        begin
          cx = st.gets
          cx or break
          if cx.length.zero?

            bucket = cx.node_payload

            _ = _quot bucket.surface_string

            @_y << "#{ bucket.leaf_bucket_symbol } [label=\"#{ _ }\"]"

            redo
          end
          ( branches ||= [] ).push cx
          redo
        end while nil

        if branches
          branches.each do | sub_tree |
            _blank_line
            __express_tree_recursive sub_tree
          end
        end
        NIL_
      end

      def __express_feature_listing

        @_y << "subgraph cluster_FEATURES {"

        _indent

        ___express_feature_section_styles

        @graph_structure.features.each do | feat |

          _label = _quot feat.surface_string

          @_y << "#{ feat.feature_symbol } [label=\"#{ _label }\"]"
        end

        _dedent
        @_y << CLOSE_CURLY__
        NIL_
      end

      CLOSE_CURLY__ = '}'

      def ___express_feature_section_styles

        # (etc:)

        if @features_section_label
          _ = _quot @features_section_label
          @_y << "label=\"#{ _ }\""
        end

        @_y << "style=filled"
        @_y << "color=lightgrey"
        @_y << "node [style=filled color=white shape=rect]"
        _blank_line
        NIL_
      end

      def __express_occurrences

        @graph_structure.occurrence_groups.each do | og |

          association_string =
            "#{ og.bucket_symbol }#{ ARROW___ }#{ og.feature_symbol }"

          d = og.occurrences.length
          if 1 == d
            @_y << association_string
          else
            @_y << "#{ association_string } [label=\"(#{ d }x)\"]"
          end
        end
        NIL_
      end

      ARROW___ = '->'

      def __done
        @upstream_line_yielder
      end

      # -- editing support

      def _blank_line
        @upstream_line_yielder << NEWLINE_  # do not indent blank lines
        NIL_
      end

      def _quot s
        if RX___ =~ s
          self._COVER_ME
        else
          s
        end
      end

      RX___ = /["\\]/

      def __build_line_yielder

        current_margin = EMPTY_S_
        margin_stack = [ current_margin ]
        indent_by = "#{ SPACE_ }#{ SPACE_ }"

        @_indent = -> do

          new_margin = "#{ current_margin }#{ indent_by }"
          margin_stack.push new_margin
          current_margin = new_margin
          NIL_
        end

        @_dedent = -> do
          if 1 == margin_stack.length
            self._CANT
          else
            margin_stack.pop
            current_margin = margin_stack.last
          end
          NIL_
        end

        up = @upstream_line_yielder

        ::Enumerator::Yielder.new do | content |

          up << "#{ current_margin }#{ content }#{ NEWLINE_ }"
        end
      end

      def _indent
        @_indent[]
      end

      def _dedent
        @_dedent[]
      end
    end
  end
end
