module Skylab::TanMan::Models::DotFile::Sexp end

module Skylab::TanMan::Models::DotFile::Sexp::InstanceModules

  module DoubleQuotedString
    def string
      content_text_value.gsub('\"', '"')
    end
  end

  module EqualsStmt
    # this is a *big* experiment -- expect this to change a lot
    def rhs= mixed
      ::String === mixed or fail('huh?')
      p = self.class.grammar.build_parser_for_rule(:id)
      node = p.parse mixed
      node ||= p.parse "\"#{mixed.gsub('"', '\"')}\""
      node or fail "sanity - what such string is invalid? #{p.failure_reason}"
      super self.class.element2tree(node, :rhs)
    end
  end

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
