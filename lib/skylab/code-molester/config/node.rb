module Skylab::CodeMolester

  module Config

    class Node < ::Treetop::Runtime::SyntaxNode

      CM_::Sexp::Auto.enhance( self ).with_sexp_auto_class Config_::Sexp_

    end
  end
end
