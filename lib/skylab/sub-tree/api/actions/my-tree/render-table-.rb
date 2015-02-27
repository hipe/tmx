module Skylab::SubTree

  class API::Actions::My_Tree

    class Render_table_ < LIB_.struct( :paystream, :row_a )

      LIB_.funcy_globful self

      def execute
        row_a = [ ]
        @row_a.each do |row|
          g_a, slug, any_leaf = row.to_a
          cel_a = [ ]
          cel_a << "#{ "#{ g_a * SPACE_ } " if g_a.length.nonzero? }#{
            }#{ slug }"
          cel_a << ( if any_leaf
            (( fs = any_leaf.any_free_cel )) ? "  #{ fs }" : EMPTY_S_
          else EMPTY_S_ end )
          row_a << cel_a
        end
        SubTree_::Lib_::CLI_table[
          :field, :id, :glyphs_and_slug, :left,
          :field, :id, :xtra, :left,
          :show_header, false,
          :left, EMPTY_S_, :sep, EMPTY_S_, :right, "\n",
          :read_rows_from, row_a,
          :write_lines_to, @paystream ]
        nil
      end
    end
  end
end
