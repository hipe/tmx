module Skylab::TanMan::Models::DotFile::Sexps

  EXTEND_F = ->(klass, rule) do
    klass.extend(
      ::Skylab::TanMan::Sexp::Auto::Lossless::Recursive::ModuleMethods)
    klass.send(:include,
      ::Skylab::TanMan::Sexp::Auto::Lossless::InstanceMethods)
    klass.rule = rule
    true
  end

  class EqualsStmt < ::Struct.new(:lhs, :e1, :e2, :e3, :rhs)
    EXTEND_F[self, :equals_stmt]
    # this is a *big* experiment -- expect this to change a lot
    def rhs= mixed
      ::String === mixed or fail('huh?')
      parser = ::Skylab::TanMan::Models::DotFile::HandMadeSupplementParser.new
      parser.root = :id
      node = parser.parse mixed
      node ||= parser.parse "\"#{mixed.gsub('"', '\"')}\""
      node or fail 'sanity'
      super self.class.element2tree(node, :rhs)
    end
  end

  class DoubleQuotedString < ::Struct.new(:e0, :content_text_value, :e2)
    EXTEND_F[self, :double_quoted_string]
    def string
      content_text_value.gsub('\"', '"')
    end
  end
end
