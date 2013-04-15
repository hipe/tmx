module Skylab::CodeMolester


  class Config::Node < ::Treetop::Runtime::SyntaxNode
    extend CodeMolester::Sexp::Auto
    sexp_factory_class Config::Sexp
  end

end
