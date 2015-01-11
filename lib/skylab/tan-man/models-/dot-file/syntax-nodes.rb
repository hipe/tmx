module Skylab::TanMan

  module Models_::DotFile

    SyntaxNodes = ::Module.new

    class SyntaxNodes::Graph < TanMan_.lib_.TT::Runtime::SyntaxNode

      def tree
        TanMan_::Sexp_::Auto::Lossless::Recursive[ self ] # :+#strain
      end
    end
  end
end
