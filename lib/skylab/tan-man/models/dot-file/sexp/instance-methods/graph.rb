module Skylab::TanMan
  module Models::DotFile::Sexp::InstanceMethods::Graph
    include Models::DotFile::Sexp::InstanceMethod::InstanceMethods

    comment_rx = Models::DotFile::Sexp::InstanceMethods::Comment::MATCH_RX

    define_method :comment_nodes do
      ::Enumerator.new do |y|
        space = -> str do
          if comment_rx =~ str
            y << str
          end
        end
        [e0, e4, e6].each(& space)
        if stmt_list
          stmt_list._nodes.each do |node|
            space[ node.e2 ]
            space[ node.tail.stmt_separator ] if node.tail
          end
        end
        [e8, e10].each(& space)
      end
    end

    def _edge_stmts
      _stmt_enumerator { |stmt| :edge_stmt == stmt.class.rule }
    end

    def _first_label_stmt
      stmt_list.stmts.detect do |s|
        :equals_stmt == s.class.rule && 'label' == s.lhs.normalized_string
      end
    end

    def get_label
      equals_stmt = _first_label_stmt
      equals_stmt.rhs.normalized_string if equals_stmt
    end

    def _named_prototype name
      stmt_list._named_prototypes[name]
    end

    def node_with_id id
      _node_stmts.detect { |n| id == n.node_id }
    end

    def _node_stmts
      _stmt_enumerator { |stmt| :node_stmt == stmt.class.rule }
    end

    def nodes
      _node_stmts.to_a
    end

    def set_label! str
      equals_stmt = _first_label_stmt
      equals_stmt ||= begin
        proto = _named_prototype(:label) or fail('no label proto')
        created = true
        proto.__dupe except: [:rhs]
      end
      equals_stmt.rhs = str
      if created
        stmt_list._insert_before! equals_stmt, _node_stmts.first
      else
        equals_stmt
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
