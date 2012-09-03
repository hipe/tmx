module Skylab::TanMan
  class Models::DotFile::SyntaxNodes::Graph < ::Treetop::Runtime::SyntaxNode
    def tree
      Sexp::Auto::Lossless::Recursive[ self ]
    end
  end
end
