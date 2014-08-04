module Skylab::SubTree

  module Tree

    class From_paths_

      Entity_[ self, :fields, :client, :paths, :init_node ]

      def execute
        root = @client.new :name_services, @client.new
        @init_node and @init_node[ root ]
        @paths.each do |path|
          root.fetch_or_create :path, path, :init_node, @init_node
        end
        root
      end
    end
  end
end
