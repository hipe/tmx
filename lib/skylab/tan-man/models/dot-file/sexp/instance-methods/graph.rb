module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods

  module Graph
    include Common
    def _create_node_with_label label
      proto = stmt_list._named_prototypes[:node_stmt] or fail('no node proto!')
      other = proto._create_node_with_label label
      h = ::Hash[ _node_stmts.map { |n| [n.node_id, true] } ]
      stem = _label2id_stem label
      use_id = stem.intern
      if h.key? stem
        i = 1 # so that the first numbered thing will be foo_2
        nil while h.key?( use_id = "#{stem}_#{i += 1}".intern )
      end
      other.node_id! use_id
      other
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
    def node! label
      # look for an exact match node by label, and if found return that.
      # if no exact match was found, hold on to any first node that was
      # lexically grater than the new label for use in an attempt at
      # alphabetically placing the new node.
      found_match = found_after = nil
      _node_stmts.each do |node_stmt|
        case node_stmt.label <=> label
        when 0
          found_match = node_stmt
          break
        when 1
          found_after ||= node_stmt
        end
      end
      if found_match
        fail("remember we want to return a node_stmt -- confirm this")
        found_match
      else
        _node_stmt = _create_node_with_label label
        _stmt_list = stmt_list._insert_before! _node_stmt, found_after
        _stmt_list[:stmt] # _node_stmt
      end
    end
    def _node_stmts
      ::Enumerator.new do |y|
        stmt_list.stmts.each do |s|
          :node_stmt == s.class.rule and y << s
        end
      end
    end
    def nodes
      _node_stmts.to_a
    end
    def set_label! str
      equals_stmt = _first_label_stmt
      equals_stmt ||= begin
        proto = stmt_list._named_prototypes[:label] or fail('no label proto')
        created = true
        proto.__dupe
      end
      equals_stmt.rhs = str
      if created
        stmt_list._insert_before! equals_stmt, _node_stmts.first
      else
        equals_stmt
      end
    end
  end
end
