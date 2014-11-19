module Skylab::TanMan

  module Models_::DotFile

    SyntaxNodes = ::Module.new

    class SyntaxNodes::Graph < TanMan_._lib.TT::Runtime::SyntaxNode

      def tree
        TanMan_::Sexp::Auto::Lossless::Recursive[ self ] # :+#strain
      end
    end
  end
end
