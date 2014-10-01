module Skylab::TanMan

  module Models_::DotFile::Sexp::InstanceMethods::Graph

    include Models_::DotFile::Sexp::InstanceMethod::InstanceMethods

    comment_rx = Models_::DotFile::Sexp::InstanceMethods::Comment.match_rx

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
      _get_stmt_scan.reduce_by do |stmt|
        :edge_stmt == stmt.class.rule
      end
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

    def set_label str
      equals_stmt = _first_label_stmt
      equals_stmt ||= begin
        proto = stmt_list._named_prototypes[:label]
        proto or fail 'no label prototype'
        created = true
        proto.__dupe except: [:rhs]
      end
      equals_stmt.rhs = str
      if created
        stmt_list._insert_item_before_item equals_stmt, node_statements.first
      else
        equals_stmt
      end
    end

    def node_with_id id
      nodes.detect do |stmt|
        id == stmt.node_id
      end
    end

    def nodes
      node_statements.map_by do |stmt_list|
        stmt_list.stmt
      end
    end

    def node_statements
      get_stmt_scan.reduce_by do |stmt_list|
        :node_stmt == stmt_list.stmt.class.rule
      end
    end

    def get_stmt_scan
      sl = stmt_list
      if sl
        sl.to_scan
      else
        Scan_[].the_empty_scan
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
