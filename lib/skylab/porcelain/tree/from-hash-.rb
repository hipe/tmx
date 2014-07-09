module Skylab::Porcelain

  module Tree

    class From_hash_

      Entity_[ self, :fields, :client, :hash ]

      def execute
        work @client.new, @hash
      end

    private

      def work parent_node, child_h
        child_node = @client.new :name_services, parent_node,
          :slug, child_h.fetch( :name )
        if (( a = child_h[:children] ))
          a.each do |h|
            work child_node, h
          end
        end
        child_node
      end
    end
  end
end
