module Skylab::Porcelain

  module Tree

    class Fetch_or_create_

      Fields_[ self,
        :client,
        :do_create,
        :else_p,
        :init_node,
        :node_payload,
        :path ]

      def execute
        _path_a = some_normalized_path_a
        node = work _path_a, @client
        @node_payload and node.set_node_payload @node_payload
        node
      end

    private

      def some_normalized_path_a
        path_a = ::Array.try_convert @path
        path_a or some_normd_path_a_when_not_array
      end

      def some_normd_path_a_when_not_array
        @path or raise ::ArgumentError, "'path' is a required iambic param."
        "#{ @path }".split @client.path_separator
      end

      def work mutable_path_a, node
        begin
          mutable_path_a.length.zero? and break( r = node )
          slug = mutable_path_a.shift
          if node.has_children
            child = node[ slug ]
          end
          if ! child
            @else_p and break r = @else_p[]
            @do_create or break
            child = node.class.new :slug, slug, :name_services, node
            @init_node and @init_node[ child ]
          end
          r = if mutable_path_a.length.zero?
            child
          else
            work mutable_path_a, child
          end
        end while nil
        r
      end
    end
  end
end
