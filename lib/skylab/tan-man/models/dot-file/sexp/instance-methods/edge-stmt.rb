module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods

  module EdgeStmt

    OPTS = ::Struct.new :attrs, :prototype

    include Common

    def _attrs! attrs
      self[:attr_list][:content][:a_list]._update_attributes! attrs
    end

    def _create source_node, target_node, o
      # assume you are the prototype
      edge_stmt = __dupe(except: [[:agent, :id], [:edge_rhs, :recipient, :id]])
      edge_stmt.source_node_id! source_node.node_id
      edge_stmt.target_node_id! target_node.node_id
      o[:attrs] and edge_stmt._attrs! o[:attrs]
      edge_stmt
    end

    def source_node_id
      self[:agent][:id].normalized_string.intern
    end

    def source_node_id! source_node_id
      o = _parse_id source_node_id.to_s
      self[:agent][:id] = o # support for 'port' at [#051]
    end

    def target_node_id
      self[:edge_rhs][:recipient][:id].normalized_string.intern
    end

    def target_node_id! target_node_id
      o = _parse_id target_node_id.to_s
      self[:edge_rhs][:recipient][:id] = o
    end
  end
end
