module Skylab::TanMan

  module Models_::DotFile::Sexp::InstanceMethods::EdgeStmt

    include Models_::DotFile::Sexp::InstanceMethod::InstanceMethods

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
