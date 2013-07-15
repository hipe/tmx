module Skylab::Porcelain

  module Tree

    class To_text_

      Fields_[ self, :client ]

      def execute
        lines = get_lines_ea
        io = Porcelain::Services::StringIO.new
        lines.each( & io.method( :puts ) )
        io.string
      end

      def get_lines_ea
        fly = Line_.new
        loc = Tree::Traversal.new
        ::Enumerator.new do |y|
          _node_count = loc.traverse @client do |card|
            fly.set loc.prefix( card ), loc.render_node( card.node )
            y << fly
          end
          Result_.new _node_count
        end
      end

      Result_ = ::Struct.new :node_count

      class Line_
        def set prefix, node
          @prefix = prefix ; @node = node
          nil
        end

        def to_s
          "#{ @prefix }#{ @node }"
        end
      end
    end
  end
end
