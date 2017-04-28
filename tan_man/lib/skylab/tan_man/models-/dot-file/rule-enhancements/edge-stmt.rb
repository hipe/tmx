module Skylab::TanMan

  module Models_::DotFile::RuleEnhancements::EdgeStmt

    include Models_::DotFile::CommonRuleEnhancementsMethods_

    def source_node_id
      self[:agent][:id].normal_content_string_.intern
    end

    def set_source_node_id source_node_id
      self[ :agent ][ :id ] = _parse_id source_node_id.to_s ; nil
      # #open [#051] support for 'port'
    end

    def target_node_id
      self[:edge_rhs][:recipient][:id].normal_content_string_.intern
    end

    def set_target_node_id target_node_id
      self[ :edge_rhs ][ :recipient ][ :id ] = _parse_id target_node_id.to_s ; nil
    end
  end
end
