module Skylab::TanMan

  module Models_::DotFile

    SyntaxNodes = ::Module.new

    class SyntaxNodes::Graph < Home_.lib_.TT::Runtime::SyntaxNode

      def tree
        Home_::Sexp_::Auto::Lossless::Recursive[ self ] # :+#strain
      end
    end
  end
end
