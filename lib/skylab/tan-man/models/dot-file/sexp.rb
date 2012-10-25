module Skylab::TanMan::Models::DotFile::Sexp end

module Skylab::TanMan::Models::DotFile::Sexp::InstanceModules
  module EqualsStmt
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

  module DoubleQuotedString
    def string
      content_text_value.gsub('\"', '"')
    end
  end
end
