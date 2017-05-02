module Skylab::TanMan

  module Models_::DotFile::RuleEnhancements::Graph

    include Models_::DotFile::CommonRuleEnhancementsMethods_

    comment_rx = Models_::DotFile::RuleEnhancements::Comment.match_rx

    define_method :comment_nodes do
      ::Enumerator.new do |y|
        space = -> str do
          if comment_rx =~ str
            y << str
          end
        end
        [e0, e4, e6].each(& space)
        if stmt_list
          stmt_list.elements_.each do |node|
            space[ node.e2 ]
            space[ node.tail.stmt_separator ] if node.tail
          end
        end
        [e8, e10].each(& space)
      end
    end

    def _edge_stmts
      _get_stmt_scan.reduce_by do |stmt|
        :edge_stmt == stmt.class.rule_symbol
      end
    end

    def _first_label_stmt
      stmt_list.stmts.detect do |sn|
        if :equals_stmt == sn.class.rule_symbol
          LABEL_LABEL_ == sn.lhs.normal_content_string_
        end
      end
    end

    def get_label
      equals_stmt = _first_label_stmt
      if equals_stmt
        equals_stmt.rhs.normal_content_string_
      end
    end

    def set_label str
      equals_stmt = _first_label_stmt
      equals_stmt ||= begin
        proto = stmt_list.named_prototypes_[ :label ]
        proto or fail 'no label prototype'
        created = true
        proto.duplicate_except_ :rhs
      end
      equals_stmt.rhs = str
      if created
        first_node_statement = to_node_statement_stream.gets
        if first_node_statement
          stmt_list.insert_item_before_item_ equals_stmt, first_node_statement
        else
          stmt_list.append_item_ equals_stmt
        end
      else
        equals_stmt
      end
    end

    def node_with_id id_sym
      nodes.detect do |stmt|
        id_sym == stmt.node_ID_symbol_
      end
    end

    def to_node_stream
      to_node_statement_stream.map_by do |stmt_list|
        stmt_list.stmt
      end
    end

    def to_node_statement_stream
     __to_stmt_stream.reduce_by do |stmt_list|
        :node_stmt == stmt_list.stmt.class.rule_symbol
      end
    end

    def __to_stmt_stream
      sl = stmt_list
      if sl
        sl.to_element_stream_
      else
        Common_::THE_EMPTY_STREAM
      end
    end

    def _stmt_enumerator &block
      ::Enumerator.new do |y|
        if stmt_list
          stmt_list.stmts.each do |stmt|
            block.call(stmt) and y << stmt
          end
        end
      end
    end
  end
end
