module Skylab::TanMan
  module Models::Association::Events
    # pure namespace, all here
  end

  TanMan::Model::Event || nil # (load it here, then it's prettier below)

  class Models::Association::Events::Created <
    Model::Event.new :edge_stmt

    def build_message
      "created association: #{ edge_stmt.unparse }"
    end
  end

  class Models::Association::Events::Disassociation_Success <
    Model::Event.new :source_node, :target_node, :edge_stmt

    def build_message
      "removed association: #{ source_node.node_id } -> #{
        }#{ target_node.node_id } (actual stmt: #{ edge_stmt.unparse }) "
    end
  end

  class Models::Association::Events::Disassociation_Successes <
    Model::Event.new :edge_stmts

    def build_message
      a = edge_stmts.map(&:unparse)
      "removed associaton#{ s a }: #{ a.join ', ' }"
    end
  end

  class Models::Association::Events::Exists <
    Model::Event.new :edge_stmt, :polarity

    def build_message
      if polarity
        "found existing association: #{ edge_stmt.unparse }"
      else
        "association already exists: #{ edge_stmt.unparse }"
      end
    end
  end

  class Models::Association::Events::No_Prototypes <
    Model::Event.new :graph_noun

    def build_message
      "the stmt_list does not have any prototypes in #{
      }#{ graph_noun } (is it at the top, after \"graph {\"?)."
    end
  end

  class Models::Association::Events::No_Prototype <
    Model::Event.new :graph_noun, :prototype_ref

    def build_message
      "the stmt_list in #{ graph_noun } has no prototype named #{
      }#{ ick prototype_ref }"
    end
  end

  class Models::Association::Events::Not_Associated <
    Model::Event.new :source_node, :target_node, :reverse_was_true

    def build_message
      "association does not exist: #{ source_node.node_id } #{
      }-> #{ target_node.node_id }"
    end
  end
end
