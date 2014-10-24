module Skylab::CodeMolester

  module Config

    class Node < ::Treetop::Runtime::SyntaxNode

      CM_::Sexp::Auto.enhance( self ).with Config_::Sexp_

    end
  end
end
