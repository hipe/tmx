module Skylab::TanMan
  module Models::Node
  end
  module Models::Node::Event
  end
  module Models::Node::Events
  end

  module Models::Node::Event::InstanceMethods
    include Core::SubClient::InstanceMethods

    def message
      @message || build_message
    end

    attr_writer :message

    def to_h
      members.reduce( message: message ) do |memo, member|
        val = self[member]
        if val.respond_to? :to_h
          val = val.to_h
        end
        memo[member] = val
        memo
      end
    end

    def to_s
      message
    end

  protected

    def initialize request_client, *a
      @message = nil
      _tan_man_sub_client_init! request_client
      members.zip( a ).each { |k, v| self[k] = v }
    end
  end


  class Models::Node::Events::Ambiguous_Node_Reference <
    ::Struct.new :node_ref, :nodes
    include Models::Node::Event::InstanceMethods

    def build_message
      "ambiguous node name #{ ick node_ref }. #{
        }did you mean #{ or_ nodes.map { |n| "#{ lbl n.label }" } }?"
    end
  end


  class Models::Node::Events::Disassociation_Success <
    ::Struct.new :source_node, :target_node, :edge_stmt
    include Models::Node::Event::InstanceMethods

    def build_message
      "removed association: #{ source_node.node_id } -> #{
        }#{ target_node.node_id } (actual stmt: #{ edge_stmt.unparse }) "
    end
  end


  class Models::Node::Events::Generic_Event_Aggregate <
    ::Struct.new :list
    include Models::Node::Event::InstanceMethods

    def build_message
      list.map(&:message).join '.  '
    end
  end


  class Models::Node::Events::Node_Not_Found <
    ::Struct.new :node_ref, :seen_count
    include Models::Node::Event::InstanceMethods

    def build_message
      "couldn't find a node whose label starts with #{
        }#{ ick node_ref } (among #{ seen_count } node#{ s seen_count })"
    end
  end


  class Models::Node::Events::Nodes_Not_Associated <
    ::Struct.new :source_node, :target_node, :reverse_was_true
    include Models::Node::Event::InstanceMethods

    def build_message
      "association does not exist: #{ source_node.node_id } #{
      }-> #{ target_node.node_id }"
    end
  end


  class Models::Node::Events::Node_Not_Founds <
    ::Struct.new :node_not_founds
    include Models::Node::Event::InstanceMethods

    def build_message
      x = node_not_founds.length ; y = node_not_founds.first.seen_count
      "couldn't find #{ s x, :a }node#{ s x, :s } whose label#{ s x } #{
      }start#{ s x, :_s } with #{
      }#{ or_ node_not_founds.map { |o| "#{ lbl o.node_ref }" } } #{
      }(among #{ y } node#{ s y })"
    end
  end
end
