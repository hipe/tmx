module Skylab::TanMan
  module Models::Node
    # (maybe one day etc but for now the sexp *is* the node)
  end


  module Models::Node::Events
    # all here.
  end


  TanMan::Model::Event || nil # (load it here, then it's prettier below)


  class Models::Node::Events::Ambiguous_Node_Reference <
    Model::Event.new :node_ref, :nodes

    def build_message
      "ambiguous node name #{ ick node_ref }. #{
        }did you mean #{ or_ nodes.map { |n| "#{ lbl n.label }" } }?"
    end
  end


  class Models::Node::Events::Disassociation_Success <
    Model::Event.new :source_node, :target_node, :edge_stmt

    def build_message
      "removed association: #{ source_node.node_id } -> #{
        }#{ target_node.node_id } (actual stmt: #{ edge_stmt.unparse }) "
    end
  end


  class Models::Node::Events::Node_Not_Found <
    Model::Event.new :node_ref, :seen_count

    def build_message
      "couldn't find a node whose label starts with #{
        }#{ ick node_ref } (among #{ seen_count } node#{ s seen_count })"
    end
  end


  class Models::Node::Events::Nodes_Not_Associated <
    Model::Event.new :source_node, :target_node, :reverse_was_true

    def build_message
      "association does not exist: #{ source_node.node_id } #{
      }-> #{ target_node.node_id }"
    end
  end


  class Models::Node::Events::Node_Not_Founds <
    Model::Event.new :node_not_founds

    def build_message
      x = node_not_founds.length ; y = node_not_founds.first.seen_count
      "couldn't find #{ s x, :a }node#{ s x, :s } whose label#{ s x } #{
      }start#{ s x, :_s } with #{
      }#{ or_ node_not_founds.map { |o| "#{ lbl o.node_ref }" } } #{
      }(among #{ y } node#{ s y })"
    end
  end
end
