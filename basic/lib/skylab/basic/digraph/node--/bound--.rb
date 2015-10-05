module Skylab::Basic

  class Digraph

    class Node__

      class Bound__

    def initialize graph, name
      @graph_ref = -> { graph }
      @normalized_local_node_name = name
    end

    attr_reader :normalized_local_node_name

    # represent a node as an external entity capable of reflecting on
    # itself vis-a-vis its graph.

    def is? otr
      sym = otr.normalized_local_node_name
      sym == @normalized_local_node_name or begin
        node = @graph_ref.call.fetch @normalized_local_node_name
        node.direct_association_targets_include sym or begin
          @graph_ref.call.indirect_association_targets_include(
            @normalized_local_node_name, sym )
        end
      end
    end

      end
    end
  end
end
