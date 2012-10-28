module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods

  module Graph
    def _first_label_stmt
      stmt_list.stmts.detect do |s|
        :equals_stmt == s.class.rule && 'label' == s.lhs.string
      end
    end
    def get_label
      equals_stmt = _first_label_stmt
      equals_stmt.rhs.string if equals_stmt
    end
    def _nodes
      ::Enumerator.new do |y|
        stmt_list.stmts.each do |s|
          :node_stmt == s.class.rule and y << s
        end
      end
    end
    def nodes
      _nodes.to_a
    end
    def set_label! str
      equals_stmt = _first_label_stmt
      equals_stmt ||= begin
        proto = stmt_list._named_prototypes[:label] or fail('no label prottype')
        created = true
        proto.__dupe
      end
      equals_stmt.rhs = str
      if created
        stmt_list._insert_before! equals_stmt, stmt_list._nodes.first
      else
        equals_stmt
      end
    end
  end
end
