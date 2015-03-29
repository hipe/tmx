module Skylab::SubTree

  module Models::Tree

    class Input_Adapters__::Paths

      attr_writer :mixed_upstream, :node_class

      def produce_tree

        cls = @node_class
        init_node = nil  # future-proofing
        paths = @mixed_upstream

        root = cls.new :name_services, cls.new

        paths.each do | path |

          root.fetch_or_create :path, path, :init_node, init_node
        end

        root
      end
    end
  end
end
