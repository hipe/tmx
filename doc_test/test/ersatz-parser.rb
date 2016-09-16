module Skylab::DocTest::TestSupport

  module Ersatz_Parser

    def self.[] tcc
      tcc.include self
    end

    # -

      TestSupport_::Define_dangerous_memoizer.call self, :grammar_one_parser_ do

        o = ersatz_lib_module_.begin

        # --

        cache = {}  # don't make a new regex for every time a branch is pushed

        o.default_branch_end_line_matcher_by do |md|
          cache.fetch md[ :margin ] do |s|
            x = /\A#{ ::Regexp.escape md[ :margin ] }end\b/
            cache[ s ] = x
            x
          end
        end

        # --

        o.add_branch_line_matcher(
          %r(\A(?<margin>[\t ]*)begin\b)

        ) do |md|
          # (separate the easy problem of above from the harder problem here)

          Home_::Models_::String.unescape_quoted_literal_anchored_at_head(
            md.post_match )
        end

        o.finish
      end

      def ersatz_lib_module_
        Home_::ErsatzParser
      end
    # -

    # ==

    recurse = nil
    Show_structure_into = -> y, nodes do
      recurse[ 0, nodes, y ]
    end

    cache = {
      0 => ""  # BASE CASE
    }
    indent = "  "

    margin_for = -> depth do
      cache.fetch depth do
        x = "#{ margin_for[ depth - 1 ] }#{ indent }"
        cache[ depth ] = x
        x
      end
    end

    recurse = -> depth, nodes, y do
      deeper = nil
      nodes.each do |node|
        if node.is_branch
          deeper ||= depth + 1
          y << "#{ margin_for[ depth ] }#{ node.category_symbol }\n"
          recurse[ deeper, node.nodes, y ]
        end
      end
      y
    end

    # ==
  end
end
