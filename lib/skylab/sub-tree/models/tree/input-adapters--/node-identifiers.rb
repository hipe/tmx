module Skylab::SubTree

  module Models::Tree

    class Input_Adapters__::Node_identifiers

      attr_writer :mixed_upstream, :node_class

      def produce_tree

        cls = @node_class

        root = cls.new :name_services, cls.new

        @mixed_upstream.each do | identifier |

          root.fetch_or_create(
            :path, identifier.to_tree_path,
            :node_payload, identifier )
        end

        root
      end
    end
  end
end
