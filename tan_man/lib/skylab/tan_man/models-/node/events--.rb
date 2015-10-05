module Skylab::TanMan

  class Models_::Node

    module Events__

  if false
  class Models::Node::Events::Destroyed <
    Model::Event.new :node_stmt

    def build_message
      "removed node: #{ lbl node_stmt.label }"
    end
  end
  end

      Found_Existing_Node = Callback_::Event.prototype_with :found_existing_node,

          :node_stmt, nil,
          :did_mutate_document, false,
          :ok, nil do | y, o |

        _s = o.node_stmt.label_or_node_id_normalized_string
        if o.ok
          y << "found existing node #{ lbl _s }"
        else
          y << "node already existed: #{ lbl _s }"
        end
      end

  if false

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
    end
  end
end