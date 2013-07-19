module Skylab::Porcelain

  module Tree

    class Fetch_or_create_

      Fields_[ self, :client, :path, :init_node, :do_create ]

      def execute
        work @path.respond_to?( :each_index ) ? @path.dup :
          @path.to_s.split( @client.path_separator ), @client
      end

    private

      def work mutable_path_a, node
        begin
          mutable_path_a.length.zero? and break( r = node )
          slug = mutable_path_a.shift
          if node.has_children
            child = node[ slug ]
          end
          if ! child
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
