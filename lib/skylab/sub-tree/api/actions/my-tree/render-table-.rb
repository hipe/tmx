module Skylab::SubTree

  class API::Actions::My_Tree

    class Render_table_ < Basic::Struct[ :paystream, :row_a ]

      MetaHell::Funcy[ self ]

      def execute
        row_a = [ ]
        @row_a.each do |row|
          g_a, slug, any_leaf = row.to_a
          cel_a = [ ]
          cel_a << "#{ "#{ g_a * ' ' } " if g_a.length.nonzero? }#{
            }#{ slug }"
          cel_a << ( if any_leaf
            (( fs = any_leaf.any_free_cel )) ? "  #{ fs }" : ''
          else '' end )
          row_a << cel_a
        end
        SubTree::Services::Face::CLI::Table[
          :field, :id, :glyphs_and_slug, :left,
          :field, :id, :xtra, :left,
          :show_header, false,
          :left, '', :sep, '', :right, '',
          :read_rows_from, row_a,
          :write_lines_to, @paystream.method( :puts ) ]
        nil
      end
    end
  end
end
