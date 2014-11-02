module Skylab::SubTree

  module Tree

    class To_paths_

      Entity_[ self, :properties, :client ]

      def execute
        @path_separator = @client.path_separator
        @a = [ ]
        work @client, nil, true
        @a
      end

      def work node, prefix=nil, is_root=false
        has_children = node.has_children
        if prefix || ! is_root
          @a << pathinate( [ prefix, node.slug, ( '' if has_children ) ] )
        end
        if has_children
          prefix_ = ( pathinate [ prefix, node.slug ] if ! is_root )
          node.children.each do |nod|
            work nod, prefix_
          end
        end
        nil
      end

      def pathinate a
        if a.length.nonzero?
          a.compact * @path_separator
        end
      end
    end
  end
end
