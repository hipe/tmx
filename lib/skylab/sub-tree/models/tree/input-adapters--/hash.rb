module Skylab::SubTree

  module Models::Tree

    Input_Adapters__ = ::Module.new

    class Input_Adapters__::Hash

      attr_writer :mixed_upstream, :node_class

      def produce_tree
        _work @node_class.new, @mixed_upstream
      end

      def _work parent_node, h

        child_node = @node_class.new(

          :slug, h.fetch( :name ),
          :name_services, parent_node )

        a = h[ :children ]
        if a
          a.each do | h_ |
            _work child_node, h_
          end
        end

        child_node
      end
    end
  end
end
