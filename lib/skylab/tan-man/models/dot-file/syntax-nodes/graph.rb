module Skylab::TanMan
  class Models::DotFile::SyntaxNodes::Graph < ::Treetop::Runtime::SyntaxNode
    def tree
      ::Skylab::TanMan::Sexp::Auto::Lossless::Recursive[ self ] #strain
    end
  end
end
