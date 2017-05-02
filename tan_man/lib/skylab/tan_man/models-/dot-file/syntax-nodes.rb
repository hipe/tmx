module Skylab::TanMan

  module Models_::DotFile

    SyntaxNodes = ::Module.new

    class SyntaxNodes::Graph < Home_.lib_.TT::Runtime::SyntaxNode

      def _to_final_parse_tree_
        Home_::Sexp_::Auto::LosslessRecursive[ self ]  # #strain
      end
    end
  end
end
