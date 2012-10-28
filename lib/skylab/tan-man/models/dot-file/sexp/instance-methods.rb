module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods
  extend ::Skylab::Autoloader

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

  self::Graph && nil # #sky-106
end
