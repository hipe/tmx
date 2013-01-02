module Skylab::TanMan
  module Models::Node::Events
    # all here.
  end

  TanMan::Model::Event || nil # (load it here, then it's prettier below)

  class Models::Node::Events::Ambiguous <
    Model::Event.new :node_ref, :nodes

    def build_message
      "ambiguous node name #{ ick node_ref }. #{
        }did you mean #{ or_ nodes.map { |n| "#{ lbl n.label }" } }?"
    end
  end

  class Models::Node::Events::Attributes_Updated <
    Model::Event.new :node_stmt, :added, :changed

    def build_message
      preds = [ ]
      if added.length.nonzero?
        preds << "added attribute#{ s added }: #{
          }[ #{ added.map { |k, v| "#{ k }=#{ v }" }.join ', ' } ]"
      end
      if changed.length.nonzero?
        preds << "changed #{ changed.map do |k, old, new|
          "#{ k } from #{ val old } to #{ val new }"
        end.join ' and ' }"
      end
      "on node #{ lbl node_stmt.label } #{ preds.join ' and ' }"
    end
  end

  class Models::Node::Events::Created <
    Model::Event.new :node_stmt

    def build_message
      "created node: #{ lbl node_stmt.label }"
    end
  end

  class Models::Node::Events::Destroyed <
    Model::Event.new :node_stmt

    def build_message
      "removed node: #{ lbl node_stmt.label }"
    end
  end

  class Models::Node::Events::Exists <
    Model::Event.new :node_stmt, :polarity

    def build_message
      if polarity
        "found existing node #{ lbl node_stmt.label }"
      else
        "node already existed: #{ lbl node_stmt.label }"
      end
    end
  end

  class Models::Node::Events::No_Prototype <
    Model::Event.new :graph_noun

    def build_message
      "the stmt_list does not have a prototype in #{
      }#{ graph_noun } (is it at the top, after \"graph {\"?)."
    end
  end

  class Models::Node::Events::Not_Found <
    Model::Event.new :node_ref, :seen_count

    def build_message
      "couldn't find a node whose label starts with #{
        }#{ ick node_ref } (among #{ seen_count } node#{ s seen_count })"
    end
  end

  class Models::Node::Events::Not_Founds <
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
