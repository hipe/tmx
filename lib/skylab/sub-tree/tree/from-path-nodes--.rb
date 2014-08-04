module Skylab::Porcelain

  module Tree

    class From_path_nodes__

      Entity_[ self, :fields, :client, :path_nodes ]

      def execute
        root = @client.new :name_services, @client.new
        @path_nodes.each do |node|
          root.fetch_or_create :path, node.to_tree_path, :node_payload, node
        end
        root
      end
    end
  end
end
