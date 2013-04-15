module Skylab::CodeMolester

  class Config::Node < ::Treetop::Runtime::SyntaxNode

    CodeMolester::Sexp::Auto.enhance( self ).with Config::Sexp

  end
end
